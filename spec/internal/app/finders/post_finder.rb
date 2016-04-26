class PostFinder
  include Findit::Cachable

  cache_methods first_post: :expire_in, :results_size, last_post: { expire_in: :expire_in_last_post }

  attr_accessor :user_id, :query

  def call
    return [] if user_id.blank? && query.blank?
    scope = Post
    scope = scope.where(user_id: user_id) if user_id.present?
    scope = scope.where('description like :query', query: query) if query.present?
    scope
  end

  def first_post
    data.first
  end

  def last_post
    data.last
  end

  def results_size
    data.size
  end
end
