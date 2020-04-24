# frozen_string_literal: true

require_relative 'resource'

module Bunq
  class Attachment
    def initialize(parent_resource, id)
      @resource = parent_resource.append("/attachment/#{id}")
    end

    def show
      @resource.with_session { @resource.get }['Response']
    end
  end
end
