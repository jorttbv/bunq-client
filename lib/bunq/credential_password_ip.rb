# frozen_string_literal: true
require_relative 'ip'

module Bunq
  class CredentialPasswordIp
    def initialize(parent_resource)
      @resource = parent_resource.append("/credential-password-ip")
    end

    def list
      @resource.with_session { @resource.get }['Response']
    end

    def ip(id)
      Bunq::Ip.new(@resource, id)
    end
  end
end
