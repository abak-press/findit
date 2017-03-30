class PostsFinder
  include Findit::Collections
  include Findit::WillPaginate

  cache_key do
    [@user.id, @query]
  end

  def initialize(user, options = {})
    @user = user
    @query = options[:query]
    @page = options[:page]
    @per_page = options[:per_page]
  end

  private

  def find
    scope = Post.where(user_id: @user.id)
    scope = scope.where('text like :query', query: "%#{@query}%") if @query.present?
    scope = scope.paginate(page: @page, per_page: @per_page) if @page && @per_page
    scope
  end
end

