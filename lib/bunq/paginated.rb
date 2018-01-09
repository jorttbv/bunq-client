require_relative 'errors'

module Bunq
  class MissingPaginationObject < UnexpectedResponse; end
  # https://doc.bunq.com/api/1/page/pagination
  class Paginated
    def initialize(resource)
      @resource = resource
    end

    def paginate(count: 200, older_id: nil, newer_id: nil)
      params = setup_params(count, older_id, newer_id)
      @resource.with_session { enumerator(params) }
    end

    private

    def setup_params(count, older_id, newer_id)
      fail ArgumentError.new('Cant pass both older_id and newer_id') if older_id && newer_id

      params = {count: count}
      params[:older_id] = older_id if older_id
      params[:newer_id] = newer_id if newer_id
      params
    end

    def enumerator(params)
      last_page = false
      next_params = params

      Enumerator.new do |yielder|
        loop do
          raise StopIteration if last_page

          result = @resource.get(next_params)
          result['Response'].each do |item|
            yielder << item
          end

          pagination = result['Pagination']
          fail MissingPaginationObject unless pagination

          last_page = !pagination['older_url']
          next_params = params.merge(older_id: param('older_id', pagination['older_url'])) unless last_page
        end
      end
    end

    def param(name, url)
      CGI.parse(URI(url).query)[name]&.first
    end
  end
end
