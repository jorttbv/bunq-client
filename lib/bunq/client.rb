require 'openssl'
require 'base64'
require 'thread_safe'

require_relative './version'
require_relative './resource'

require_relative './installations'
require_relative './installation'
require_relative './device_servers'
require_relative './encryptor'
require_relative './session_servers'
require_relative './user'
require_relative './user_company'
require_relative './user_person'
require_relative './monetary_account'
require_relative './monetary_accounts'
require_relative './payment'
require_relative './payments'
require_relative './signature'
require_relative './attachment_public_content.rb'

##
# Usage
#
#   Bunq.configure do |config|
#     config.api_key = 'YOUR_APIKEY'
#     config.installation_token = 'YOUR_INSTALLATION_TOKEN'
#     config.private_key = 'YOUR PRIVATE KEY'
#     config.server_public_key = 'SERVER PUBLIC KEY'
#   end
#
#   client = Bunq.client
#   number_of_accounts = client.me_as_user.monetary_accounts.index.to_a.count
#   puts "User has #{number_of_accounts} accounts"
#
module Bunq
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)

      configuration.base_url = Configuration::SANDBOX_BASE_URL if configuration.sandbox
    end

    def reset_configuration
      self.configuration = nil
    end

    ##
    # Returns a new instance of +Client+ with the current +configuration+.
    #
    def client
      fail 'No configuration! Call Bunq.configure first.' unless configuration

      Client.new(configuration.dup)
    end
  end

  class NoSessionCache
    def get(&block)
      block.call if block_given?
    end

    def clear
      # no-op
    end
  end

  ##
  # A thread-safe session cache that can hold one (the current) session.
  #
  # Usage:
  #
  # Bunq.configure do |config|
  #   config.session_cache = Bunq::ThreadSafeSessionCache.new
  # end
  #
  # After this, all +Bunq.client+ calls will use the same session. When the session times out,
  # a new one is started automatically.
  #
  class ThreadSafeSessionCache
    CACHE_KEY = 'CURRENT_BUNQ_SESSION'.freeze

    def initialize
      clear
    end

    def get(&block)
      @cache.fetch_or_store(CACHE_KEY) { block.call if block_given? }
    end

    def clear
      @cache = ThreadSafe::Cache.new
    end
  end

  ##
  # Configuration object for connecting to the bunq api
  #
  class Configuration
    SANDBOX_BASE_URL = 'https://public-api.sandbox.bunq.com'.freeze
    PRODUCTION_BASE_URL = 'https://api.bunq.com'.freeze

    DEFAULT_LANGUAGE = 'nl_NL'.freeze
    DEFAULT_REGION = 'nl_NL'.freeze
    DEFAULT_GEOLOCATION = '0 0 0 0 000'.freeze
    DEFAULT_USER_AGENT = "bunq ruby client #{Bunq::VERSION}".freeze
    DEFAULT_TIMEOUT = 60
    DEFAULT_SESSION_CACHE = NoSessionCache.new

    # Base url for the bunq api. Defaults to +PRODUCTION_BASE_URL+
    attr_accessor :base_url,
                  # Flag to set to connect to sandbox. Defaults to +false+.
                  # If set to +true+ you must also specify +sandbox_user+
                  # and +sandbox_password+
                  :sandbox,
                  # The username for connecting to the sandbox
                  :sandbox_user,
                  # The password for connecting to the sandbox
                  :sandbox_password,
                  # Your installation token obtained from bunq
                  :installation_token,
                  # Your api key obtained from bunq
                  :api_key,
                  # Your language. Defaults to  +DEFAULT_LANGUAGE+
                  :language,
                  # Your region. Defaults to  +DEFAULT_REGION+
                  :region,
                  # Your geolocation. Defaults to +DEFAULT_GEOLOCATION+
                  :geolocation,
                  # Arbitrary user agent to connect to bunq. Defaults to +DEFAULT_USER_AGENT+
                  :user_agent,
                  # Flag to set when you want to disable the signature
                  # retrieved from bunq. Mainly useful for testing.
                  # Defaults to +false+
                  :disable_response_signature_verification,
                  # The private key for signing the request
                  :private_key,
                  # The public key of this installation for verifying the response
                  :server_public_key,
                  # Timeout in seconds to wait for bunq api. Defaults to +DEFAULT_TIMEOUT+
                  :timeout,
                  # Cache to retrieve current session from. Defaults to +DEFAULT_SESSION_CACHE+,
                  # which will create a new session per `Bunq.client` instance.
                  # See +ThreadSafeSessionCache+ for more advanced use.
                  :session_cache

    def initialize
      @sandbox = false
      @base_url = PRODUCTION_BASE_URL
      @language = DEFAULT_LANGUAGE
      @region = DEFAULT_REGION
      @geolocation = DEFAULT_GEOLOCATION
      @user_agent = DEFAULT_USER_AGENT
      @disable_response_signature_verification = false
      @timeout = DEFAULT_TIMEOUT
      @session_cache = DEFAULT_SESSION_CACHE
    end
  end

  ##
  # The Bunq::Client is the adapter for the Bunq Public Api (doc.bunq.com)
  #
  # An instance of a +Client+ can be obtained via +Bunq.client+
  class Client
    attr_accessor :current_session
    attr_reader :configuration

    def initialize(configuration)
      fail ArgumentError, 'configuration is required' unless configuration

      @configuration = configuration
    end

    def installations
      Bunq::Installations.new(self)
    end

    def installation(id)
      Bunq::Installation.new(self, id)
    end

    def device_servers
      Bunq::DeviceServers.new(self)
    end

    def session_servers
      Bunq::SessionServers.new(self)
    end

    def user(id)
      Bunq::User.new(self, id)
    end

    def user_company(id)
      Bunq::UserCompany.new(self, id)
    end

    def user_person(id)
      Bunq::UserPerson.new(self, id)
    end

    # Returns the +Bunq::AttachmentPublicContent+ represented by the given id
    def attachment_public_content(id)
      with_session { Bunq::AttachmentPublicContent.new(self, id) }
    end

    # Returns the +Bunq::UserPerson+ represented by the +Bunq::Configuration.api_key+
    def me_as_user_person
      with_session { user_person(current_session_user_id) }
    end

    # Returns the +Bunq::UserCompany+ represented by the +Bunq::Configuration.api_key+
    def me_as_user_company
      with_session { user_company(current_session_user_id) }
    end

    # Returns the +Bunq::User+ represented by the +Bunq::Configuration.api_key+
    def me_as_user
      with_session { user(current_session_user_id) }
    end

    def with_local_config
      yield(configuration.dup)
    end

    def ensure_session!
      @current_session ||= configuration.session_cache.get { create_session }
    end

    def create_session
      session_servers.create
    end

    def with_session(&block)
      retries ||= 0
      ensure_session!
      block.call
    rescue UnauthorisedResponse => e
      configuration.session_cache.clear
      @current_session = nil
      retry if (retries += 1) < 2
      raise e
    end

    def signature
      @signature ||= Signature.new(configuration.private_key, configuration.server_public_key)
    end

    def encryptor
      @encryptor ||= Encryptor.new(configuration.server_public_key)
    end

    def headers
      {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
        'Content-Type': 'application/json',
        'User-Agent': configuration.user_agent,
        'X-Bunq-Language': configuration.language,
        'X-Bunq-Geolocation': configuration.geolocation,
        'X-Bunq-Region': configuration.region,
      }.tap do |h|
        h[:'X-Bunq-Client-Authentication'] = configuration.installation_token if configuration.installation_token

        h[:'X-Bunq-Client-Authentication'] = current_session[1]['Token']['token'] if current_session
      end
    end

    def current_session_user_id
      current_session[2].first[1]['id']
    end
  end
end
