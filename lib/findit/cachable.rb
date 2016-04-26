#
#  Module for lazy load of result collection for finder
#
#  Example usage:
#
#  #/app/finders/posts_finders.rb
#  class PostsFinder
#    include Findit::Cachable
#
#    def initialize(options)
#      @user = options[:user]
#    end
#
#    def call
#      Post.where(user_id: user.id)
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
#  - cache(@post_finder, tags: @post_finder.tags, expire_in: @post_finder.expire_in) do
#    =render 'post' colection: @post_finder, as: :post
#
#
module Findit
  module Cacheble
    include Enumerable
    extend ActiveSupport::Concern
    attr_reader :cache_key

    module ClassMethods
      def cache_methods(*methods)
        Array.wrap(methods).each do |method|
          case method
          when Hash
            method.each do |name, args|
              define_method name do
                wrapped_key = ActiveSupport::Cache.expand_cache_key(cache_key)
                args =
                  if args.is_a?(Hash)
                    args.map { |k, v| [k, public_send(v)] }
                  else
                    Array.wrap(args).map { |k| [k, public_send(k)] }
                  end
                args = Hash[args]
                Rails.cache.fetch("#{cache_key}/#{method}", args) do
                  public_send(name)
                end
              end
            end
          when Symbol, String
            define_method method do
              wrapped_key = ActiveSupport::Cache.expand_cache_key(cache_key)
              Rails.cache.fetch("#{cache_key}/#{method}") do
                public_send(method)
              end
            end
          else
            raise NameError, "Can't create method name from class - #{method.class}"
          end
        end
      end
    end

    def initialize(args)
      args.each do |k, v|
        singleton_class.class_eval { attr_reader k }
        instance_variable_set("@{k}", v)
      end

      @ignore = Array.wrap((@ignore || []) + [:ignore])

      @cache_key = args.select { |k, _| !ignore.include?(k) }
    end

    def call
      raise NotImplementedError
    end

    def data
      @data ||= call
    end

    def each(&block)
      data.each(&block)
    end

    def [](index)
      data[index]
    end
  end
end
