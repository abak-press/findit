class CachedPostFinder
  include ::Findit::Single
  include ::Findit::Cache

  cache_key do
    @user.id
  end

  cache_options do
    {expires_in: 15.minutes}
  end

  def initialize(user, options = {})
    @user = user
    @use_cache = !options[:no_cache]
  end

  private

  def find
    Post.where(user_id: @user.id).last
  end
end
