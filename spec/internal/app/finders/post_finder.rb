class PostFinder
  include Findit::Collections

  cache_methods :first, :last

  cache_key do
    [@user.id, @query]
  end

  cache_tags do
    {user_id: @user.id}
  end

  expire_in 30.minutes

  def initialize(user, options = {})
    @user = user
    @query = options[:query]
  end

  def call
    scope = Post.where(user_id: @user.id)
    scope = scope.where('text like :query', query: "%#{@query}%") if @query.present?
    scope
  end
end
