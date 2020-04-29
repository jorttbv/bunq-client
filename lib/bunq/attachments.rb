# frozen_string_literal: true

require 'base64'

module Bunq
  class Attachments
    def initialize(parent_resource)
      @resource = parent_resource.append('/attachment')
    end

    def create(binary_payload, description, mime_type)
      custom_headers = {
        Bunq::Header::CONTENT_TYPE => mime_type,
        Bunq::Header::ATTACHMENT_DESCRIPTION => description,
      }
      payload = Base64.decode64(binary_payload)
      @resource.with_session { @resource.post(payload, custom_headers: custom_headers) }['Response']
    end
  end
end
