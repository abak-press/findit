#
#  Example usage:
#
#  #/app/finders/posts_finders.rb
#  class CachedPostFinder
#    include Findit::Cache
#
#    cache_key do
#      [@user.id, @query]
#    end
#
#    cache? do
#      !@no_cache
#    end
#
#    cache_options do
#      {expire_in: 15.minutes}
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
#    def show
#      @post = CachedPostFinder.new(user: current_user).call
#    end
#  end
#
#  #/app/views/posts/index.html.erb
#  # Already cached in finder itself
#  <%= render 'post', post: @post%>
#
#  # OR if you call it in another finder
#  class CommentOnMyLastPostFinder
#    include Findit::Collections
#
#    def initialize(user)
#      @user = user
#    end
#
#    private
#
#    def find
#      last_post.comments
#    end
#
#    def last_post
#      @post = CachedPostFinder.new(user).call
#    end
#  end
#
module Findit
  module Cache
    extend ActiveSupport::Concern

    module ClassMethods
      def cache_options(&block)
        define_method(:cache_options) do
          instance_exec(&block)
        end
      end
    end

    included do
      set_callback :find, :around do |object, block|
        if !defined?(@cache) || @cache
          options = respond_to?(:cache_options) && cache_options
          @data = Rails.cache.fetch(object.cache_key, options) { block.call }
        else
          block.call
        end
      end
    end

    def without_cache
      @cache = false
      self
    end
  end
end
