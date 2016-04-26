require 'spec_helper'

Rspec.describe Findit do
  let(:user) { User.create }
  let(:other_user) { User.create }

  let!(:user_post_0) { Post.create(user_id: user.id, text: 'This is simple post') }
  let!(:user_post_1) { Post.create(user_id: user.id, text: 'Simpliest post ever') }
  let!(:user_post_2) { Post.create(user_id: user.id, text: 'Some post') }
  let!(:other_user_post_0) { Post.create(user_id: User.create.id, text: 'Simplest post for other user') }

  let(:finder) {PostFinder.new(user_id: user.id, query: query) }
  let(:query) { 'simpl' }
  let(:user_id) { user.id }

  describe '#data' do
    it 'returns results' do
      expect(finder.size).to eq 3
    end
  end

  describe '#each' do
    it 'iterates over results' do
      expect(finder.map(&:id)).to match_array [user_post_0.id, user_post_1]
    end
  end

  describe '#cache_key' do
    it 'returns key by params' do
      expect(finder.cache_key).to eq(user_id: user_id, query: query)
    end

    context 'with ignore list' do
      let(:finder) { PostFinder.new(user_id: user_id, query: query, expire_in: 10.minutes, ignore: :expire_in) }

      it 'ignore list in cache_key' do
        expect(finder.cache_key).to eq(user_id: user_id, query: query)
      end
    end
  end

  describe '#[]' do
    let(:user_id) { other_user.id }
    it 'works as on array' do
      expect(finder[0]).to eq other_user_post_0.id
    end
  end

  describe '#cache_methods' do
    let(:cache_key) { cache_key = ActiveSupport::Cache.expand_cache_key(user_id: user_id, query: query) }
    it 'cache method' do
      expect(Rails.cache).to recieve(:fetch).with("#{cache_key}/result_size")
      finder.result_size
    end

    it 'allow to pass custom argument' do
      finder = PostFinder.new(user_id: user_id, query: query, expire_in: 10.minutes, ignore: :expire_in)
      expect(Rails.cache).to recieve(:fetch).with("#{cache_key}/result_size", expire_in: 10.minutes)
      finder.first_post
    end

    it 'allow to pass custom argument as hash' do
      finder = PostFinder.new(
        user_id: user_id,
        query: query,
        expire_in: 10.minutes,
        expire_in_last_post: 1.minute,
        ignore: [:expire_in, :expire_in_last_post]
      )
      expect(Rails.cache).to recieve(:fetch).with("#{cache_key}/result_size", expire_in: 10.minutes)
      finder.first_post
    end
  end
end
