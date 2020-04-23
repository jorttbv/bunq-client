# frozen_string_literal: true
module Bunq
  class Card
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/card/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end

    def update(card)
      @resource.with_session { @resource.put(card, encrypt: true) }['Response']
    end
  end
end
