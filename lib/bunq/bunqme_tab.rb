# frozen_string_literal: true

module Bunq
  class BunqmeTab
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/bunqme-tab/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end

    def update(attributes)
      @resource.with_session { @resource.put(attributes) }['Response']
    end
  end
end
