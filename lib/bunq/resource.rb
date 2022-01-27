# frozen_string_literal: true

require_relative 'errors'
require 'restclient'
require 'json'

module Bunq
  class Resource
    APPLICATION_JSON = 'application/json'

    NO_PARAMS = {}.freeze
    NO_BODY = nil

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

    def post(payload, skip_verify: false, encrypt: false, custom_headers: {}, &block)
      custom_headers = JSON.parse(custom_headers.to_json)
      body = post_body(payload, custom_headers)
      body, headers = client.encryptor.encrypt(body) if encrypt
      headers = headers.to_h.merge(custom_headers)

      headers = bunq_request_headers('POST', NO_PARAMS, body, headers)

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

    def delete(&block)
      headers = bunq_request_headers('DELETE', NO_PARAMS, NO_BODY)

      resource.delete(headers) do |response, request, result|
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
        end,
      )
    end

    def bunq_request_headers(verb, params, payload = nil, headers = {})
      headers[Bunq::Header::CLIENT_REQUEST_ID] = SecureRandom.uuid

      unless @path.end_with?('/installation') && verb == 'POST'
        headers[Bunq::Header::CLIENT_SIGNATURE] = sign_request(verb, params, headers, payload)
      end

      headers
    end

    def sign_request(_verb, _params, _headers, payload = nil)
      client.signature.create(payload)
    end

    def encode_params(path, params)
      return path if params.empty?

      "#{path}?#{URI.escape(params.collect { |k, v| "#{k}=#{v}" }.join('&'))}"
    end

    def verify_and_handle_response(response, request, result, &block)
      client.signature.verify!(response) if verify_response_signature?(response)
      handle_response(response, request, result, &block)
    end

    def verify_response_signature?(response)
      return false if client.configuration.disable_response_signature_verification
      return false if response.code == 491

      (100..499).include?(response.code)
    end

    def handle_response(response, _request, _result)
      if response.code == 200 || response.code == 201
        if block_given?
          yield(response)
        else
          JSON.parse(response.body)
        end
      elsif (response.code == 409 && Bunq.configuration.sandbox) || response.code == 429
        fail TooManyRequestsResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      elsif [401, 403].include?(response.code)
        fail UnauthorisedResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      elsif response.code == 404
        fail ResourceNotFound.new(code: response.code, headers: response.raw_headers, body: response.body)
      elsif [491, 503].include?(response.code)
        fail MaintenanceResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      else
        fail UnexpectedResponse.new(code: response.code, headers: response.raw_headers, body: response.body)
      end
    end

    def post_body(payload, custom_headers)
      if custom_headers.key?(Bunq::Header::CONTENT_TYPE) &&
         custom_headers[Bunq::Header::CONTENT_TYPE] != APPLICATION_JSON
        payload
      else
        JSON.generate(payload)
      end
    end
  end
end
