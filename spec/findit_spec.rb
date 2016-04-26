require 'spec_helper'

RSpec.describe Findit do
  let(:user) { User.create }
  let(:other_user) { User.create }

  let!(:user_post_0) { Post.create(user_id: user.id, text: 'This is simple post') }
  let!(:user_post_1) { Post.create(user_id: user.id, text: 'simpliest post ever') }
  let!(:user_post_2) { Post.create(user_id: user.id, text: 'Some post') }
  let!(:other_user_post_0) { Post.create(user_id: other_user.id, text: 'simplest post for other user') }

  let(:finder) {PostFinder.new(finder_user, query: query) }
  let(:query) { 'simpl' }
  let(:finder_user) { user }

  describe '#data' do
    it 'returns results' do
      expect(finder.size).to eq 2
    end
  end

  describe '#each' do
    it 'iterates over results' do
      expect(finder.map(&:id)).to match_array [user_post_0.id, user_post_1.id]
    end
  end

  describe '#cache_key' do
    it 'returns key by params' do
      expect(finder.cache_key).to eq [user.id, query]
    end
  end

  describe '#cache_tags' do
    it 'return proper one' do
      expect(finder.cache_tags).to eq({user_id: user.id})
    end
  end

  describe '#expire_in' do
    it 'return proper one' do
      expect(finder.expire_in).to eq 30.minutes
    end
  end

  describe '#[]' do
    let(:finder_user) { other_user }
    it 'works as on array' do
      expect(finder[0]).to eq other_user_post_0
    end
  end

  describe '#cache_methods' do
    let(:cache_key) { cache_key = ActiveSupport::Cache.expand_cache_key([user.id, query]) }
    it 'cache method' do
      expect(Rails.cache).to receive(:fetch).with("#{cache_key}/first", cache_tags: {user_id: user.id}, expire_in: 30.minutes)
      finder.first
    end
  end
end
