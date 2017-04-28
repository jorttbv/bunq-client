require_relative 'qr_code_content'

module Bunq
  class DraftShareInviteBanks
    def initialize(parent_resource)
      @resource = parent_resource.append("/draft-share-invite-bank")
    end

    def create(invite)
      @resource.with_session { @resource.post(invite) }['Response']
    end

    def index
      @resource.with_session { @resource.get }['Response']
    end
  end
end
