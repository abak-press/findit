#
#  Example usage:
#
#  #/app/finders/posts_finders.rb
#  class PostFinder
#    include Findit::Collections
#
#    cache_key do
#      [@user.id, @query]
#    end
#
#    def initialize(user, options = {})
#      @user = user
#      @query = options[:query]
#    end
#
#    private
#
#    def find
#      scope = scope.where(user_id: @user.id)
#      scope = scope.where('description like :query', query: @query) if @query.present?
#      scope
#    end
#  end
#
#  #/app/controllers/posts_controller.rb
#  class PostsController < ApplicationController
#    def index
#      @posts = PostFinder.new(user: current_user)
#    end
#  end
#
#  #/app/views/posts/index.html.erb
#  <% cache(@posts, tags: @posts.cache_tags, expire_in: @posts.expire_in) do %>
#    <%= render 'post' colection: @posts, as: :post%>
#
module Findit
  module Collections
    include Enumerable
    include ::Findit::Single
    extend ActiveSupport::Concern

    included do
      delegate :each, :[], :size, :empty?, :to_ary, :to_a, to: :call
    end
  end
end
