# Findit

Tired of writing fat controllers? But you must do all these queries.. There is a solution, move it to a special Finder class!

Stop writing this:

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

Just do this:
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

  private

  def find
    # put here you find logic
  end
end
```

And that it! Now you can iterate over finder results by simple `each`:
```ruby
@scope = SomeFinder.new(params)
@scope.each do |d|
  print d.description
end
```
or perform caching like ActiveRecord::Base
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

It makes Finder work as Enumerator with lazy load.
Result can be accessed with `each`, `[]` and `size` methods, but to make things work you *must* implement `find` method.
```
  class PostFinder
    incliude Findit::Collections

    private # make it private, so no one call it without lazy load

    def find
      Post.where(user_id: 1)
    end
  end

  @posts = PostFinder.new

  # load all matching posts and iterate over collection
  @posts.each do |post|
    print post.title
  end

  @posts[10] # get 10 element of posts

  @posts.size # size of PostFinder results

  # Also you can access result direcly by using `data` method.
  @posts.data # access to all posts

```

For easier caching expirience we provide DSL to define you custom `cache_key`

```ruby
#/app/finders/posts_finders.rb
class PostFinder
  include Findit::Collections

  cache_key do
    [@user.id, @query] # here you put any stuff that result of finder depend on it
  end

  # custom initializer, do whatever you want here
  def initialize(options = {})
    @user = options.fetch(:user)
    @query = options[:query]
  end

  private
  # Here we fetch results. You MUST implement it
  def find
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

#/app/views/posts/index.html.erb
<% cache(@posts, expire_in: 30.minutes) do %>
   <%=render 'post', collection: @posts, as: :post%> # it will automaticly iterate over finder results by each method
```

### WillPaginate

It adds delegation of [will_paginate](https://github.com/mislav/will_paginate) methods to finder.

Example usage:

```ruby
# app/finders/post_finder.rb
class PostFinder
  include Findit::Collection
  include Findit::WillPaginate

  cache_key do
    [@page, @per_page]
  end

  def initialize(page, per_page)
    @page = page
    @per_page = per_page
  end

  private

  def find
    scope = Post.paginate(per_page: per_page, page: page)
  end
end

# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  def index
    @posts = PostFinder.new(params[:page], params[:per_page])
  end
end

# app/views/posts/index.html.erb
<% cache(@posts, expire_in: 30.minutes) do %>
  <%= render 'post', collection: @posts, as: :post %>
  <%= will_paginate @posts %>
```

### Single

Adds DSL for cache_key on Finder with single element to find.

Example usage:

```ruby
# app/finders/post_finder.rb
class PostsFinder
  include Findit::Single

  cache_key do
    @user
  end

  def initialize(user)
    @user = user
  end

  private

  def find
    Post.where(user: user).last
  end
end
```

### Cache

Extends finder with cache possibility. Every call of `call` method will be cached in `Rails.cache`.
Method `cache options` allows you to add custom options like `expire_in` or `tags` to `Rails.cache.fetch`.
If you want to disable cache dependent of initialization arguments, you can use `cache?` DSL method.

All in one Example:
```ruby
# app/finders/post_finder.rb
class CachedPostsFinder
  include Findit::Single
  include Findit::Cache

  cache_key do
    @user
  end

  cache_options do
    {expire_in: 15.minutes} # This will be directly passed to Rails.cache.fetch
  end

  def initialize(user)
    @user = user
  end

  private

  def find
    Post.where(user: user)
  end
end
```

To disable cache for some reasone you can call special method without_cache:

```ruby
CachedFinder.new(user).without_cache.load # no cache

CachedFinder.new(user).load - # will perform cache operations
```


If you want this functionality on Collections finder you can add extension `Findit::Collections` alongside with Cache:
```ruby
class SomeFinder
  include Findit::Collections
  include Findit::Cache

  ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abak-press/findit.
