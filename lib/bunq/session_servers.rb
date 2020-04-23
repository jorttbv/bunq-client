module Bunq
  ##
  # https://doc.bunq.com/api/1/call/session-server
  class SessionServers
    def initialize(client)
      @resource = Bunq::Resource.new(client, '/v1/session-server')
      @api_key = client.configuration.api_key
    end

    ##
    # https://doc.bunq.com/api/1/call/session-server/method/post
    def create
      fail 'Cannot create session, please add the api_key to your configuration' unless @api_key

      @resource.post(secret: @api_key)['Response']
    end
  end
end
