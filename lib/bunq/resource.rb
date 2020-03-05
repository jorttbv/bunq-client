require_relative 'errors'
require 'restclient'
require 'json'

module Bunq
  class Resource
    attr_reader :resource
    NO_PARAMS = {}

    def initialize(client, path)
      @client = client
      @path = path
    end

    def get(params = {}, &block)
      resource.get({params: params}.merge(bunq_request_headers('GET', params))) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end


    def post(payload, skip_verify: false, encrypt: false, &block)
      body = JSON.generate(payload)
      body, headers = client.encryptor.encrypt(body) if encrypt

      headers = bunq_request_headers('POST', NO_PARAMS, body, headers || {})

      resource.post(body, headers) do |response, request, result|
        if skip_verify
          handle_response(response, request, result, &block)
        else
          verify_and_handle_response(response, request, result, &block)
        end
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end

    def put(payload, encrypt: false, &block)
      body = JSON.generate(payload)
      body, headers = client.encryptor.encrypt(body) if encrypt

      headers = bunq_request_headers('PUT', NO_PARAMS, body, headers || {})

      resource.put(body, headers) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end

    def append(path)
      Bunq::Resource.new(client, @path + path)
    end

    def with_session(&block)
      client.with_session(&block)
    end

    private

    attr_reader :client, :path

    def resource
      RestClient::Resource.new(
        "#{client.configuration.base_url}#{path}",
        {
          headers: client.headers,
          timeout: client.configuration.timeout,
        }.tap do |x|
          if client.configuration.sandbox
            x[:user] = client.configuration.sandbox_user
            x[:password] = client.configuration.sandbox_password
          end
        end
      )
    end

    def bunq_request_headers(verb, params, payload = nil, headers = {})
      headers['X-Bunq-Client-Request-Id'] = SecureRandom.uuid

      unless @path.end_with?('/installation') && verb == 'POST'
        headers['X-Bunq-Client-Signature'] = sign_request(verb, params, headers, payload)
      end

      headers
    end

    def sign_request(verb, params, headers, payload = nil)
      client.signature.create(
        verb,
        encode_params(@path, params),
        resource.headers.merge(headers),
        payload
      )
    end

    def encode_params(path, params)
      return path if params.empty?
      "#{path}?#{URI.escape(params.collect { |k, v| "#{k}=#{v}" }.join('&'))}"
    end

    def verify_and_handle_response(response, request, result, &block)
      handle_maintenance(response) if response.code == 491 || 503
      client.signature.verify!(response) unless client.configuration.disable_response_signature_verification
      handle_response(response, request, result, &block)
    end

    def handle_maintenance(response)
      fail MaintenanceResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
    end

    def handle_response(response, _request, _result, &block)
      if response.code == 200 || response.code == 201
        if block_given?
          yield(response)
        else
          JSON.parse(response.body)
        end
      elsif (response.code == 409 && Bunq.configuration.sandbox) || response.code == 429
        fail TooManyRequestsResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      elsif response.code == 401
        fail UnauthorisedResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      elsif response.code == 404
        fail ResourceNotFound.new(code: response.code, headers: response.raw_headers, body: response.body)
      else
        fail UnexpectedResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      end
    end
  end
end
