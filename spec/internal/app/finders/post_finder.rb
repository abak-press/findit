class PostFinder
  include Findit::Collections

  cache_key do
    [@user.id, @query]
  end

  def initialize(user, options = {})
    @user = user
    @query = options[:query]
  end

  def call
    scope = Post.where(user_id: @user.id)
    scope = scope.where('text like :query', query: "%#{@query}%") if @query.present?
    scope
  end

  def first_post
    cache('first_post') do
      data.first
    end
  end
end
