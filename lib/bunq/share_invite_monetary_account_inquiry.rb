# frozen_string_literal: true

module Bunq
  class ShareInviteMonetaryAccountInquiry
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/share-invite-monetary-account-inquiry/#{id}")
    end

    def update(inquiry)
      @resource.with_session { @resource.put(inquiry) }['Response']
    end
  end
end
