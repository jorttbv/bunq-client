# frozen_string_literal: true

module Bunq
  class RequestInquiries
    def initialize(parent_resource)
      @resource = parent_resource.append('/request-inquiry')
    end

    def create(inquiry)
      @resource.with_session { @resource.post(inquiry) }['Response']
    end
  end
end
