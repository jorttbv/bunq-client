module Bunq
  class Cards
    def initialize(parent_resource)
      @resource = parent_resource.append('/card')
    end

    def index
      @resource.with_session { @resource.get }['Response']
    end
  end
end
