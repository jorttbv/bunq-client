module Bunq
  class UnexpectedResponse < StandardError; end
  class AbsentResponseSignature < StandardError; end
  class TooManyRequestsResponse < StandardError; end
  class Timeout < StandardError; end
end
