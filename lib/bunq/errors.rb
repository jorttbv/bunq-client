# frozen_string_literal: true

module Bunq
  class ResponseError < StandardError
    attr_reader :code
    attr_reader :headers
    attr_reader :body

    def initialize(msg = 'Response error', code: nil, headers: nil, body: nil)
      @code = code
      @headers = headers || {}
      @body = body
      super("#{msg} (code: #{code}, body: #{body})")
    end

    # Returns the parsed body if it is a JSON document, nil otherwise.
    # @param opts [Hash] Optional options that are passed to `JSON.parse`.
    def parsed_body(opts = {})
      if @body && @headers['content-type'] && @headers['content-type'].include?('application/json')
        JSON.parse(
          @body,
          opts,
        )
      end
    end

    # Returns an array of errors returned from the API, or nil if no errors are returned.
    # @return [Array|nil]
    def errors
      json = parsed_body
      json ? json['Error'] : nil
    end
  end

  class UnexpectedResponse < ResponseError; end
  class InvalidResponseSignature < ResponseError; end
  class AbsentResponseSignature < ResponseError; end
  class TooManyRequestsResponse < ResponseError; end
  class UnauthorisedResponse < ResponseError; end
  class ResourceNotFound < ResponseError; end
  class Timeout < StandardError; end
  class MaintenanceResponse < ResponseError; end
end
