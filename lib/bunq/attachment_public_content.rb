module Bunq
  ##
  # https://doc.bunq.com/api/1/call/attachment-public-content
  class AttachmentPublicContent
    def initialize(client, id)
      @resource = Bunq::Resource.new(client, "/v1/attachment-public/#{id}/content")
    end

    ##
    # https://doc.bunq.com/api/1/call/attachment-public-content/method/list
    # Returns the raw content of a public attachment with given ID.
    # The raw content is the binary representation of a file.
    def show
      @resource.with_session do
        @resource.get { |response| response.body }
      end
    end
  end
end
