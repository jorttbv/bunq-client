require_relative 'paginated'

module Bunq
  # https://doc.bunq.com/api/1/call/payment
  class Payments
    def initialize(parent_resource)
      @resource = parent_resource.append("/payment")
    end

    # https://doc.bunq.com/api/1/call/payment/method/list
    def index(count: 200, older_id: nil, newer_id: nil)
      Bunq::Paginated
        .new(@resource)
        .paginate(count: count, older_id: older_id, newer_id: newer_id)
    end

    # https://doc.bunq.com/api/1/call/payment/method/get
    def show(id)
      @resource = @resource.append("/#{id}")
      @resource.with_session { @resource.get }['Response']
    end
  end
end
