# frozen_string_literal: true

module Bunq
  class MonetaryAccountBank
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/monetary-account-bank/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end

    def update(attributes)
      @resource.with_session { @resource.put(attributes) }['Response']
    end
  end
end
