# frozen_string_literal: true

module Bunq
  class Installation
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/installation/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
