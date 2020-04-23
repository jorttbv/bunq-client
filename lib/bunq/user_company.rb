# frozen_string_literal: true
require_relative 'resource'
require_relative 'draft_share_invite_bank'

module Bunq
  class UserCompany
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/user-company/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end

    def update(user_company)
      @resource.with_session { @resource.put(user_company) }['Response']
    end
  end
end
