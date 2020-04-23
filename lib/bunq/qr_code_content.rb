# frozen_string_literal: true

module Bunq
  class QrCodeContent
    def initialize(parent_resource)
      @resource = parent_resource.append('/qr-code-content')
    end

    def show
      @resource.with_session do
        @resource.get { |response| response.body }
      end
    end
  end
end
