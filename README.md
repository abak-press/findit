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

#/app/views/posts/index.html.haml
<% cache(@posts, expire_in: 30.minutes) do %>
   <%=render 'post' colection: @posts, as: :post%> # it will automaticly iterate over finder results by each method
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/findit.
