require 'openssl'
require 'base64'

require_relative './version'
require_relative './resource'

require_relative './installations'
require_relative './installation'
require_relative './device_servers'
require_relative './session_servers'
require_relative './user'
require_relative './user_company'
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
      fail "No configuration! Call Bunq.configure first." unless configuration
      Client.new(configuration)
    end
  end

  ##
  # Configuration object for connecting to the bunq api
  #
  class Configuration
    SANDBOX_BASE_URL = 'https://public-api.sandbox.bunq.com'
    PRODUCTION_BASE_URL = 'https://api.bunq.com'

    DEFAULT_LANGUAGE = 'nl_NL'
    DEFAULT_REGION = 'nl_NL'
    DEFAULT_GEOLOCATION = '0 0 0 0 000'
    DEFAULT_USER_AGENT = "bunq ruby client #{Bunq::VERSION}"
    DEFAULT_TIMEOUT = 60

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
      :timeout

    def initialize
      @sandbox = false
      @base_url = PRODUCTION_BASE_URL
      @language = DEFAULT_LANGUAGE
      @region = DEFAULT_REGION
      @geolocation = DEFAULT_GEOLOCATION
      @user_agent = DEFAULT_USER_AGENT
      @disable_response_signature_verification = false
      @timeout = DEFAULT_TIMEOUT
    end
  end

  ##
  # The Bunq::Client is the adapter for the Bunq Public Api (doc.bunq.com)
  #
  # An instance of a +Client+ can be obtained via +Bunq.client+
  class Client
    SessionData = Struct.new(:token, :user_id, :expires_in)

    # @type SessionData
    attr_accessor :current_session
    attr_reader :configuration
    attr_reader :signature

    def initialize(configuration)
      fail ArgumentError.new('configuration is required') unless configuration
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

    # Returns the +Bunq::AttachmentPublicContent+ represented by the given id
    def attachment_public_content(id)
      with_session { Bunq::AttachmentPublicContent.new(self, id) }
    end

    # Returns the +Bunq::UserCompany+ represented by the +Bunq::Configuration.api_key+
    def me_as_user_company
      with_session { user_company(current_session_user_id) }
    end

    # Returns the +Bunq::User+ represented by the +Bunq::Configuration.api_key+
    def me_as_user
      with_session { user(current_session_user_id) }
    end

    def ensure_session!
      @current_session ||= begin
        session = session_servers.create

        timeout = session[2].dig('UserApiKey', 'requested_by_user', 'UserPerson', 'session_timeout') ||
          session[2].dig('UserPerson', 'session_timeout') ||
          session[2].dig('UserCompany', 'session_timeout')

        SessionData.new(
          session[1]['Token']['token'],
          session[2].first[1]['id'],
          timeout
        )
      end
    end

    def with_session(&block)
      ensure_session!
      block.call
    end

    def signature
      Signature.new(configuration.private_key, configuration.server_public_key)
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
        if configuration.installation_token
          h[:'X-Bunq-Client-Authentication'] = configuration.installation_token
        end

        if current_session
          h[:'X-Bunq-Client-Authentication'] = current_session.token
        end
      end
    end

    def current_session_user_id
      current_session.user_id
    end
  end
end
