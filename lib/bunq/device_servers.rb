module Bunq
  ##
  # See https://doc.bunq.com/api/1/call/device-server
  class DeviceServers

    ##
    # +client+ an instance of +Bunq::Client+
    #
    def initialize(client)
      @resource = Bunq::Resource.new(client, "/v1/device-server")
      @client = client
    end

    ##
    # https://doc.bunq.com/api/1/call/device-server/method/post
    def create(description)
      fail ArgumentError.new('description is required') unless description

      @resource.post(description: description, secret: @client.configuration.api_key)['Response']
    end

    ##
    # https://doc.bunq.com/api/1/call/device-server/method/list
    def index
      @resource.get['Response']
    end
  end
end
