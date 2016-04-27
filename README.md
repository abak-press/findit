# Findit

Tied of writing fat controllers? But you must do all these queries.. There is a solution, move all this stuff to Finder class.

Instead of writing

```ruby
class SomeController
  def index
    @cache_key = (
      # many_values
    )
    return if fragment_exists?(@cache_key)
    search_scope = SearchEngine.scope
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    search_scope.add(some_conditions)
    result = search_scope.search_and_return_ids
    @scope = scope.where(ids: result)
    ....
  end
end
```

Do this:
```ruby
# /app/controllers/some_controller.rb
class SomeController
  def index
    @scope = SomeFinder.new(params)
  end
end

# app/finders/some_finder.rb
class SomeFinder
  include Findit::Collections

  cache_key do
    # calculate you cache_key from params
  end

  def initialize(params)
    # some initialize, maybe params parse
  end

  def call
    # put here you find logic
  end
end
```

And that it! Now you can iterate over finder results by simple each:
```ruby
@scope = SomeFinder.new(params)
@scope.each do |d|
  print d.description
end
```
or perform caching like you'll do it with ActiveRecord
```ruby
# app/some_view
<% cache @scope do %>
  <%scope.each do |res|%>
    ...
  <%end%>
<%end%>

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'findit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install findit

## Per module documentation

### Collections

It make Finder work as Enumerator . Result can be accessed with `each`, `[]` and `size` methods, but for make things work you *must* implement `call` method. Also you can access result direcly by using `data` method.

For easier caching expirience we provide DSL to define you custom `cache_key`, `cache_tags` or/and `expire_in` (for invalidation)

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
class PostsController < ApplicationController
  def index
    @posts = PostFinder.new(user: current_user)
  end
end

#/app/views/posts/index.html.haml
<% cache(@posts, tags: @posts.cache_tags, expire_in: @posts.expire_in) do %>
   <%=render 'post' colection: @posts, as: :post%> # it will automaticly iterate over finder results by each method

```

### Pagination Caching

Caching of [will_paginate](https://github.com/mislav/will_paginate) `total_pages` and `total_entries` methods.
To use it you *must* implement `data` method. Or you can combine it with Collections described earlier

Example uage with Collection
```ruby
# /app/finders/post_finder.rb
class PostFinder
  include Findit::Collection
  include Findit::Pagination

  cache_key do
    ...
  end

  expire_in do
    ...
  end

  def initialize(options)
    @conditions = options.fetch(:conditions)
    @page = options[:page] if options[:page].present?
    @per_page = options[:per_page] if options[:per_page].present?
  end

  def call
    scope = Post.where(conditions)
    scope.paginate(page, per_page, scope.count)
    scope
  end
end

# /app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = PostFinder(
      cache_key: "posts/#{current_user}/#{params[:page]}",
      conditions: { user: current_user }
      page: params[:page]
    )

    # Queries will run only when on non-cached records
    response.headers['X-TOTAL-PAGES'] = @posts.total_pages
    response.headers['X-TOTAL-ENTRIES'] = @posts.total_entries
  end
end

# /app/views/posts/index.json.jbuilder
json.cache! @posts, expire_in: @posts.expire_in do
  json.partial! 'post', collection: @posts, as: :post
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/findit.
