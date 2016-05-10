module Findit
  module WillPaginate
    extend ActiveSupport::Concern

    included do
      delegate :current_page, :per_page, :total_entries, :total_pages, to: :call
    end
  end
end
