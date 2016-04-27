#
# Example usage
#
#  /app/finders/post_finder.rb
# class PostFinder
#   include Findit::Collections
#   include Findit::Pagination
#
#   cache_key do
#     "#{user}/#{page}"
#   end
#
#   def initialize(params)
#     @user = options.fetch(:user)
#     @page = options[:page] if options[:page].present?
#   end
#
#   def call
#     scope = Post.where(conditions)
#     scope.paginate(page, per_page, scope.count)
#     scope
#   end
# end
#
# /app/controllers/post_controller.rb
# class PostsController < ApplicationController
#   def index
#     @posts = PostFinder.new(
#       user: current_user
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
