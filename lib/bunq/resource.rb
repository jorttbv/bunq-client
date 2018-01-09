require_relative 'signature'
require_relative 'response_errors'
require_relative 'timeout'
require 'restclient'
require 'json'

module Bunq
  class Resource
    attr_reader :resource
    NO_PARAMS = {}

    def initialize(client, path)
      @client = client
      @path = path
      @resource = RestClient::Resource.new(
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

    def get(params = {}, &block)
      @resource.get({params: params}.merge(bunq_request_headers('GET', params))) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end


    def post(payload, skip_verify = false, &block)
      json = JSON.generate(payload)
      if skip_verify
        @resource.post(json, bunq_request_headers('POST', NO_PARAMS, json)) do |response, request, result|
          handle_response(response, request, result, &block)
        end
      else
        @resource.post(json, bunq_request_headers('POST', NO_PARAMS, json)) do |response, request, result|
          verify_and_handle_response(response, request, result, &block)
        end
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end

    def put(payload, &block)
      json = JSON.generate(payload)
      @resource.put(json, bunq_request_headers('PUT', NO_PARAMS, json)) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
    rescue RestClient::Exceptions::Timeout
      raise Bunq::Timeout
    end

    def append(path)
      Bunq::Resource.new(client, @path + path)
    end

    def ensure_session!
      client.ensure_session!
    end

    def with_session(&block)
      client.with_session(&block)
    end

    private

    attr_reader :client

    def bunq_request_headers(verb, params, payload = nil)
      request_id_header = {'X-Bunq-Client-Request-Id' => SecureRandom.uuid}

      return request_id_header if @path.end_with?('/installation') && verb == 'POST'
      request_id_header.merge('X-Bunq-Client-Signature' => sign_request(verb, params, request_id_header, payload))
    end

    def sign_request(verb, params, request_id_header, payload = nil)
      Bunq.signature.create(
        verb,
        encode_params(@path, params),
        @resource.headers.merge(request_id_header),
        payload
      )
    end

    def encode_params(path, params)
      return path if params.empty?
      "#{path}?#{URI.escape(params.collect { |k, v| "#{k}=#{v}" }.join('&'))}"
    end

    def verify_and_handle_response(response, request, result, &block)
      Bunq.signature.verify!(response) unless client.configuration.disable_response_signature_verification
      handle_response(response, request, result, &block)
    end

    def handle_response(response, _request, _result, &block)
      case response.code
      when 200, 201
        if block_given?
          yield(response)
        else
          JSON.parse(response.body)
        end
      else
        fail UnexpectedResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      end
    end
  end
end
