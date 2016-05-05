class PostFinder
  include Findit::Collections

  cache_key do
    [@user.id, @query]
  end

  def initialize(user, options = {})
    @user = user
    @query = options[:query]
  end

  private

  def find
    scope = Post.where(user_id: @user.id)
    scope = scope.where('text like :query', query: "%#{@query}%") if @query.present?
    scope
  end
end

