#
#  Module for lazy load of result collection for finder
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
#    cache_tags do
#      {user_id: @user.id}
#    end
#
#    expire_in 30.minutes
#
#    def initialize(user, options = {})
#      @user = user
#      @query = options[:query]
#    end
#
#    def call
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
#
module Findit
  module Collections
    include Enumerable
    extend ActiveSupport::Concern

    included do
      delegate :each, :[], :size, to: :data
    end

    module ClassMethods
      def cache_key(&block)
        define_method :cache_key do
          @cache_key ||= ActiveSupport::Cache.expand_cache_key(instance_exec(&block))
        end
      end

      def cache_tags(&block)
        define_method :cache_tags do
          @cache_tags ||= instance_exec(&block)
        end
      end

      def expire_in(arg)
        define_method :expire_in do
          @expire_in ||= arg
        end
      end
    end

    def call
    end
    undef :call

    def cache(key_path)
      options = {}
      options[:cache_tags] = cache_tags if respond_to?(:cache_tags)
      options[:expire_in] = expire_in if respond_to?(:expire_in)
      Rails.cache.fetch("#{cache_key}/#{key_path}", options) do
        yield
      end
    end

    def data
      return @data if defined?(@data)
      @data = call
    end
  end
end
