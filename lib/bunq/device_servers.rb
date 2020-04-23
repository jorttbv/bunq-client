# frozen_string_literal: true
module Bunq
  ##
  # See https://doc.bunq.com/api/1/call/device-server
  class DeviceServers
    ##
    # +client+ an instance of +Bunq::Client+
    #
    def initialize(client)
      @resource = Bunq::Resource.new(client, '/v1/device-server')
      @client = client
    end

    ##
    # https://doc.bunq.com/api/1/call/device-server/method/post
    #
    # You can add a wildcard IP by passing an array of the current IP,
    # and the `*` character. E.g.: ['1.2.3.4', '*'].
    #
    # @param description [String] The description of this device server.
    # @param permitted_ips [Array|nil] Array of permitted IP addresses.
    def create(description, permitted_ips: nil)
      fail ArgumentError, 'description is required' unless description
      fail 'Cannot create session, please add the api_key to your configuration' unless @client.configuration.api_key

      params = {description: description, secret: @client.configuration.api_key}
      params[:permitted_ips] = permitted_ips if permitted_ips

      @resource.post(params)['Response']
    end

    ##
    # https://doc.bunq.com/api/1/call/device-server/method/list
    def index
      @resource.get['Response']
    end
  end
end
