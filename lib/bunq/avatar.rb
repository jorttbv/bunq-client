# frozen_string_literal: true

require_relative 'resource'

module Bunq
  class Avatar
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/avatar/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
