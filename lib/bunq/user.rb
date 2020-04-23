# frozen_string_literal: true

require_relative 'resource'
require_relative 'monetary_account'
require_relative 'monetary_accounts'
require_relative 'draft_share_invite_bank'
require_relative 'draft_share_invite_banks'
require_relative 'certificate_pinned'
require_relative 'card'
require_relative 'cards'
require_relative 'notification_filter_url'

module Bunq
  class User
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/user/#{id}")
    end

    def monetary_account(id)
      Bunq::MonetaryAccount.new(@resource, id)
    end

    def monetary_accounts
      Bunq::MonetaryAccounts.new(@resource)
    end

    def draft_share_invite_bank(id)
      Bunq::DraftShareInviteBank.new(@resource, id)
    end

    def draft_share_invite_banks
      Bunq::DraftShareInviteBanks.new(@resource)
    end

    def certificate_pinned
      Bunq::CertificatePinned.new(@resource)
    end

    def card(id)
      Bunq::Card.new(@resource, id)
    end

    def cards
      Bunq::Cards.new(@resource)
    end

    def notification_filter_url
      Bunq::NotificationFilterUrl.new(@resource)
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
