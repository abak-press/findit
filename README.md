# Findit

A collection of modules for customization your finders.
Require rails >= 3.1 and ruby >= 1.9.3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'findit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install findit

## Usage

### Collections

It makes Finder work as Enumerator with `each`, `[]` and `size` methods. For fetch result that can be accessed with these method you *must* implement `call` method. Also you can access result direcly by using `data` method

For easier caching expirience we provide DSL to define you dependency for `cache_key` and `cache_tags` or/and `expire_in` (for invalidation)

Full example with [rails-cache-tags](https://github.com/take-five/rails-cache-tags):
```ruby
#/app/finders/posts_finders.rb
class PostFinder
  include Findit::Collections

  cache_key do
    [@user.id, @query] # here you put any stuff that result of finder depend on it
  end

  cache_tags do
    {user_id: @user.id} # cache tags for invalidation
  end

  # Or/And you can use time invalidation
  expire_in 30.minutes # just value

  def initialize(user, options = {})
    @user = user
    @query = options[:query]
  end

  # Here we fetch results
  def call
    scope = scope.where(user_id: @user.id)
    scope = scope.where('description like :query', query: @query) if @query.present?
    scope
  end
end

#/app/controllers/posts_controller.rb
class SomeController < ApplicationController
  def index
    @post_finder = PostFinder.new(user: current_user)
  end
end

#/app/views/posts/index.html.haml
- cache(@post_finder, tags: @post_finder.cache_tags, expire_in: @post_finder.expire_in) do
   =render 'post' colection: @post_finder, as: :post # it will automaticly iterate over finder results by each method

```

### Pagination Caching

Caching of [will_paginate](https://github.com/mislav/will_paginate) `total_pages` and `total_entries` methods.
To use it you *must* implement `data` method. Or you can combine it with Collections described earlier

Usage with Collection
```ruby
# /app/finders/post_finder.rb
class PostFinder
  include Finder::Pagination

  def initialize(options)
    @cache_key = options.fetch(:cache_key)
    @conditions = options.fetch(:conditions)
    @page = options[:page] if options[:page].present?
    @per_page = options[:per_page] if options[:per_page].present?
  end

  def data
    @data ||= Rails.cache.fetch(cache_key) do
      scope = Post.where(conditions)
      scope.paginate(page, per_page, scope.count)
      scope
    end
  end
end

# /app/controllers/post_controller.rb
class PostCOntroller < ApplicationController
  def index
    result = PostFinder(
      cache_key: "posts/#{current_user}/#{params[:page]}",
      conditions: { user: current_user }
      page: params[:page]
    )

    render json: { posts: result, pages: result.total_pages, total: result.total_entries }
  end
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/findit.
