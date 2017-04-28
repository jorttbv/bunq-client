require_relative 'signature'
require_relative 'unexpected_response'
require 'restclient'
require 'json'

module Bunq
  class Resource
    attr_reader :resource

    def initialize(client, path)
      @client = client
      @path = path
      @resource = RestClient::Resource.new(
        "#{client.configuration.base_url}#{path}",
        {
          headers: client.headers
        }.tap do |x|
          if client.configuration.sandbox
            x[:user] = client.configuration.sandbox_user
            x[:password] = client.configuration.sandbox_password
          end
        end
      )
    end

    def get(params = {}, &block)
      @resource.get(params: params) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
    end

    def post(payload, skip_verify = false, &block)
      if skip_verify
        @resource.post(JSON.generate(payload)) do |response, request, result|
          handle_response(response, request, result, &block)
        end
      else
        @resource.post(JSON.generate(payload)) do |response, request, result|
          verify_and_handle_response(response, request, result, &block)
        end
      end
    end

    def put(payload, &block)
      @resource.put(JSON.generate(payload)) do |response, request, result|
        verify_and_handle_response(response, request, result, &block)
      end
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
