# frozen_string_literal: true

module Bunq
  ##
  # https://doc.bunq.com/api/1/call/certificate-pinned
  class CertificatePinned
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/certificate-pinned/#{id}")
    end

    def delete
      @resource.with_session { @resource.delete }['Response']
    end
  end
end
