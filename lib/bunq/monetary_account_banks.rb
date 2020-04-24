# frozen_string_literal: true

require_relative 'paginated'

module Bunq
  class MonetaryAccountBanks
    def initialize(parent_resource)
      @resource = parent_resource.append('/monetary-account-bank')
    end

    def index(count: 200, older_id: nil, newer_id: nil)
      Bunq::Paginated
        .new(@resource)
        .paginate(count: count, older_id: older_id, newer_id: newer_id)
    end

    def create(attributes)
      @resource.with_session { @resource.post(attributes) }['Response']
    end
  end
end
