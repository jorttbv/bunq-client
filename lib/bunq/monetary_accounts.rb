module Bunq
  ##
  # https://doc.bunq.com/api/1/call/monetary-account
  class MonetaryAccounts
    def initialize(parent_resource)
      @resource = parent_resource.append("/monetary-account")
    end

    # https://doc.bunq.com/api/1/call/monetary-account-bank/method/list
    def index(count: 200, older_id: nil, newer_id: nil)
      Bunq::Paginated
        .new(@resource)
        .paginate(count: count, older_id: older_id, newer_id: newer_id)
    end
  end
end
