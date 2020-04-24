# frozen_string_literal: true

require 'base64'

module Bunq
  class Attachments
    def initialize(parent_resource)
      @resource = parent_resource.append('/attachment')
    end

    def create(binary_payload, description, mime_type)
      custom_headers = {
        Bunq::Resource::HEADER_CONTENT_TYPE => mime_type,
        Bunq::Resource::HEADER_ATTACHMENT_DESCRIPTION => description,
      }
      payload = Base64.decode64(binary_payload)
      @resource.with_session { @resource.post(payload, custom_headers: custom_headers) }['Response']
    end
  end
end
