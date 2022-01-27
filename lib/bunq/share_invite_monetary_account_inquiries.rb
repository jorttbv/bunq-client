# frozen_string_literal: true

module Bunq
  class ShareInviteMonetaryAccountInquiries
    def initialize(parent_resource)
      @resource = parent_resource.append("/share-invite-monetary-account-inquiry")
    end

    # https://doc.bunq.com/#/share-invite-monetary-account-inquiry/CREATE_ShareInviteMonetaryAccountInquiry_for_User_MonetaryAccount
    def create(inquiry)
      @resource.with_session { @resource.post(inquiry) }['Response']
    end

    def index
      @resource.with_session { @resource.get }['Response']
    end
  end
end
