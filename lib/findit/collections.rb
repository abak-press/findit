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
module Findit
  module Collections
    include Enumerable
    extend ActiveSupport::Concern

    included do
      delegate :each, :[], :size, :empty?, to: :data
    end

    module ClassMethods
      def cache_key(&block)
        define_method :cache_key do
          @cache_key ||= ActiveSupport::Cache.expand_cache_key(instance_exec(&block), self.class.name.underscore)
        end
      end
    end

    def call
    end
    undef :call

    def data
      return @data if defined?(@data)
      @data = call
    end
  end
end
