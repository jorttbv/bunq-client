# frozen_string_literal: true
require_relative 'ips'

module Bunq
  class CredentialPasswordIps
    def initialize(parent_resource)
      @resource = parent_resource.append("/credential-password-ip")
    end

    def index
      @resource.with_session { @resource.get }['Response']
    end

    def ip(id)
      Bunq::Ips.new(@resource, id)
    end
  end
end
