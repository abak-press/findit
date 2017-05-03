class ArrayPostsFinder < PostsFinder
  private

  def find
    super.to_a
  end
end
