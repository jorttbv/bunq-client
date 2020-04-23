module Bunq
  # https://doc.bunq.com/#/notification-filter-url
  class NotificationFilterUrl
    def initialize(parent_resource)
      @resource = parent_resource.append('/notification-filter-url')
    end

    def create(notification_filters)
      @resource.with_session { @resource.post({notification_filters: notification_filters}) }['Response']
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
