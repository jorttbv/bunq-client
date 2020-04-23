# frozen_string_literal: true

module Bunq
  class Installations
    def initialize(client)
      @resource = Bunq::Resource.new(client, '/v1/installation')
    end

    def create(public_key)
      fail ArgumentError, 'public_key is required' unless public_key

      @resource.post({client_public_key: public_key}, skip_verify: true)['Response']
    end

    def index
      @resource.get['Response']
    end
  end
end
