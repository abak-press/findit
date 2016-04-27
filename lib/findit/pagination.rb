module Findit
  module Pagination
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
