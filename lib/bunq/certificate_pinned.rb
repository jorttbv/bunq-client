# frozen_string_literal: true

module Bunq
  ##
  # https://doc.bunq.com/api/1/call/certificate-pinned
  class CertificatePinned
    def initialize(parent_resource)
      @resource = parent_resource.append('/certificate-pinned')
    end

    ##
    # https://doc.bunq.com/api/1/call/certificate-pinned/method/post
    def create(pem_certificate)
      @resource.with_session do
        @resource.post(
          {
            certificate_chain: [
              {certificate: pem_certificate},
            ],
          },
        )
      end
    end
  end
end
