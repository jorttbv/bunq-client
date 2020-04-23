# frozen_string_literal: true

require_relative 'qr_code_content'

module Bunq
  class DraftShareInviteBank
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/draft-share-invite-bank/#{id}")
    end

    def qr_code_content
      Bunq::QrCodeContent.new(@resource)
    end
  end
end
