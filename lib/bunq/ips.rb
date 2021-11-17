# frozen_string_literal: true

module Bunq
  class Ips
    def initialize(parent_resource, id)
      fail ArgumentError, 'id is required' if id.nil?

      @resource = parent_resource.append("/#{id}/ip")
    end

    def index
      @resource.with_session { @resource.get }['Response']
    end

    def show(id)
      @resource.with_session { @resource.append("/#{id}").get }['Response']
    end

    def create(ip_address, status)
      fail ArgumentError, 'ip_address is required' if ip_address.nil?
      fail ArgumentError, 'status is required' if status.nil?

      @resource.with_session { @resource.post({ ip: ip_address, status: status }) }['Response']
    end
  end
end
