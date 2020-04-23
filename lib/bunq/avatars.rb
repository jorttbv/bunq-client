require_relative 'resource'

module Bunq
  class Avatars
    def initialize(client)
      @resource = Bunq::Resource.new(client, "/v1/avatar")
    end

    def create(attachment_public_uuid)
      @resource.with_session { @resource.post(attachment_public_uuid: attachment_public_uuid) }['Response']
    end
  end
end
