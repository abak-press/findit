#
#  Example usage:
#
#  #/app/finders/post_finders.rb
#  class PostFinder
#    include Findit::Single
#
#    cache_key do
#      [@user.id, @query]
#    end
#
#    def initialize(user, options = {})
#      @user = user
#      @query = options.fetch(:query)
#    end
#
#    private
#
#    def find
#      post = scope.find_by('description like :query', query: @query)
#    end
#  end
#
#  #/app/controllers/posts_controller.rb
#  class PostsController < ApplicationController
#    def show
#      @post = PostFinder.new(current_user, query: 'some desc')
#    end
#  end
#
#  #/app/views/posts/show.html.erb
#  <% cache(@post, expires_in: 15.minutes) do %>
#    <%= render 'post', post: @post.load%>
#
module Findit
  module Single
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :find
    end

    module ClassMethods
      def cache_key(&block)
        define_method :cache_key do
          @cache_key ||= ActiveSupport::Cache.expand_cache_key(instance_exec(&block), self.class.name.underscore)
        end
      end
    end

    def find
    end
    undef :find

    def call
      return @data if defined?(@data)
      res = run_callbacks(:find) { find }
      @data ||= res
    end
    alias_method :load, :call
  end
end
