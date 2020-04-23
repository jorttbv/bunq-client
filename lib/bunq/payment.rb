# frozen_string_literal: true

module Bunq
  # https://doc.bunq.com/api/1/call/payment
  class Payment
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/payment/#{id}")
    end

    # https://doc.bunq.com/api/1/call/payment/method/get
    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
