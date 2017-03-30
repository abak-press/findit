class PostFinder
  include Findit::Single

  cache_key do
    @user.id
  end

  def initialize(user)
    @user = user
  end

  private

  def find
    Post.where(user_id: @user.id).first
  end
end
