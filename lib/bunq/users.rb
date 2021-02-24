# frozen_string_literal: true

require_relative 'paginated'

module Bunq
  class Users
    def initialize(client)
      @resource = Bunq::Resource.new(client, "/v1/user")
    end

    def index(count: 200, older_id: nil, newer_id: nil)
      Bunq::Paginated
        .new(@resource)
        .paginate(count: count, older_id: older_id, newer_id: newer_id)
    end
  end
end
