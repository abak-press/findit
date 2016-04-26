#
#  Module for lazy load of result collection for finder
#
#  Example usage:
#
#  #/app/finders/posts_finders.rb
#  class PostFinder
#    include Findit::Collections
#
#    cache_method :first
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
#  class SomeController < ApplicationController
#    def index
#      @post_finder = PostFinder.new(user: current_user)
#    end
#  end
#
#  #/app/views/posts/index.html.haml
#  - cache(@post_finder, tags: @post_finder.cache_tags, expire_in: @post_finder.expire_in) do
#    =render 'post' colection: @post_finder, as: :post
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
      def cache_method(method)
        define_method(method) do
          key = ActiveSupport::Cache.expand_cache_key(cache_key)
          Rails.cache.fetch("#{key}/#{method}", cache_tags: cache_tags, expire_in: expire_in) do
            data.public_send(method)
          end
        end
      end

      def cache_methods(*methods)
        methods.each{ |m| cache_method(m) }
      end

      def cache_key(&block)
        define_method :cache_key do
          @cache_key ||= instance_exec(&block)
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
      raise NotImplementedError
    end

    def data
      @data ||= call
    end
  end
end
