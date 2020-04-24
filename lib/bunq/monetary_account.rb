# frozen_string_literal: true

require_relative 'notification_filter_url'
require_relative 'bunqme_tab'
require_relative 'bunqme_tabs'

module Bunq
  ##
  # https://doc.bunq.com/api/1/call/monetary-account
  class MonetaryAccount
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/monetary-account/#{id}")
    end

    def bunqme_tab(id)
      Bunq::BunqmeTab.new(@resource, id)
    end

    def bunqme_tabs
      Bunq::BunqmeTabs.new(@resource)
    end

    def payment(id)
      Bunq::Payment.new(@resource, id)
    end

    def payments
      Bunq::Payments.new(@resource)
    end

    ##
    # https://doc.bunq.com/api/1/call/monetary-account/method/get
    def show
      @resource.with_session { @resource.get }['Response']
    end

    def notification_filter_url
      Bunq::NotificationFilterUrl.new(@resource)
    end
  end
end
