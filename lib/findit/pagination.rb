#
# Example usage
#
#  /app/finders/post_finder.rb
# class PostFinder
#   include Finder::Pagination
#
#   def initialize(options)
#     @cache_key = options.fetch(:cache_key)
#     @conditions = options.fetch(:conditions)
#     @page = options[:page] if options[:page].present?
#     @per_page = options[:per_page] if options[:per_page].present?
#   end
#
#   def data
#     @data ||= Rails.cache.fetch(cache_key) do
#       scope = Post.where(conditions)
#       scope.paginate(page, per_page, scope.count)
#       scope
#     end
#   end
# end
#
# /app/controllers/post_controller.rb
# class PostsController < ApplicationController
#   def index
#     @posts = PostFinder(
#       cache_key: "posts/#{current_user}/#{params[:page]}",
#       conditions: { user: current_user }
#       page: params[:page]
#     )
#     response.headers['X-TOTAL-PAGES'] = @posts.total_pages
#     response.hesders['X-TOTAL-ENTRIES'] = @posts.total_entries
#   end
# end
#
# /app/views/posts/post.json.jbuilder
# json.cache! @posts do
#   json.partial! 'posts', collection: @posts, as: :post
# end
#
module Findit
  module Pagination
    def page
      @page ||= 1
    end

    def per_page
      @per_page ||= 30
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
