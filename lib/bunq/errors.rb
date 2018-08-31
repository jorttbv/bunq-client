module Bunq
  class UnexpectedResponse < StandardError;
    attr_reader :code
    attr_reader :headers
    attr_reader :body

    def initialize(msg = "Unexpected response", code: nil, headers: nil, body: nil)
      @code = code
      @headers = headers
      @body = body
      super(msg)
    end
  end

  class AbsentResponseSignature < StandardError; end
  class TooManyRequestsResponse < StandardError; end
  class Timeout < StandardError; end
  class Unauthorized < StandardError; end
end
