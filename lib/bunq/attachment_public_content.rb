module Bunq
  class AttachmentPublicContent
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/attachment-public/#{id}/content")
    end

    def show
      @resource.with_session do 
        @resource.get { |response| response.body }
      end
    end
  end
end
