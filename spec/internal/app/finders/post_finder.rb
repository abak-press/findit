class PostFinder
  include Findit::Collections
  include Findit::Paginate

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
    @page = options[:page] || 1
  end

  def call
    scope = Post.where(user_id: @user.id)
    scope = scope.where('text like :query', query: "%#{@query}%") if @query.present?
    scope = paginate(scope, @page, 5, scope.count)
    scope
  end

  def first_post
    cache('first_post') do
      data.first
    end
  end
end
