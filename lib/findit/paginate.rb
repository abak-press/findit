module Findit
  module Paginate
    def paginate(collection, page, per_page, total)
      ::WillPaginate::Collection.create(page, per_page, total) do |pager|
        pager.replace(collection)
      end
    end

    def total_pages
      cache('total_pages') do
        data.total_pages
      end
    end

    def total_entries
      cache('total_entries') do
        data.total_entries
      end
    end
  end
end
