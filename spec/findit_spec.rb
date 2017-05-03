require 'spec_helper'

RSpec.describe Findit do
  let(:user) { User.create }
  let(:other_user) { User.create }

  let!(:user_post_0) { Post.create(user_id: user.id, text: 'This is simple post') }
  let!(:user_post_1) { Post.create(user_id: user.id, text: 'simpliest post ever') }
  let!(:user_post_2) { Post.create(user_id: user.id, text: 'Some post') }
  let!(:other_user_post_0) { Post.create(user_id: other_user.id, text: 'simplest post for other user') }

  context 'collection' do
    let(:finder) { PostsFinder.new(finder_user, query: query) }
    let(:query) { 'simpl' }
    let(:finder_user) { user }

    describe '#data' do
      it 'returns results' do
        expect(finder.size).to eq 2
      end
    end

    describe '#load' do
      it 'finds record' do
        expect(finder.load.map(&:id)).to match_array [user_post_0.id, user_post_1.id]
      end
    end

    describe '#each' do
      it 'iterates over results' do
        expect(finder.map(&:id)).to match_array [user_post_0.id, user_post_1.id]
      end
    end

    describe '#cache_key' do
      it 'returns key by params' do
        expect(finder.cache_key).to eq "posts_finder/#{user.id}/#{query}"
      end
    end

    describe '#[]' do
      let(:finder_user) { other_user }
      it 'works as on array' do
        expect(finder[0]).to eq other_user_post_0
      end
    end

    describe '#shift' do
      let(:finder) { ArrayPostsFinder.new(finder_user, query: query) }
      let(:finder_user) { other_user }
      it 'works as on array' do
        expect(finder.shift).to eq other_user_post_0
        expect(finder.shift).to be_nil
      end
    end
  end

  context 'cache' do
    describe '#call', caching: true do
      context 'when caching is enabled' do
        it 'caches result' do
          expect(CachedPostFinder.new(user).call).to eq user_post_2
          Post.create(user_id: user.id, text: 'Some post')
          expect(CachedPostFinder.new(user).call).to eq user_post_2
        end

        it 'caches result for collection finder too' do
          expect(CachedPostsFinder.new(user, query: 'simpl').map(&:id)).to(
            match_array [user_post_0.id, user_post_1.id]
          )

          Post.create(user_id: user.id, text: 'simpliest post ever')

          expect(CachedPostsFinder.new(user, query: 'simpl').map(&:id)).to(
            match_array [user_post_0.id, user_post_1.id]
          )
        end
      end

      context 'when no_cache is set' do
        it 'fetch result on every call' do
          expect(CachedPostFinder.new(user).without_cache.call).to eq user_post_2
          new_post = Post.create(user_id: user.id, text: 'Some post')
          expect(CachedPostFinder.new(user).without_cache.call).to eq new_post
        end

        it 'fetch result for collection finder on every call' do
          expect(CachedPostsFinder.new(user, query: 'simpl').without_cache.map(&:id)).to(
            match_array [user_post_0.id, user_post_1.id]
          )

          new_post = Post.create(user_id: user.id, text: 'simpliest post ever')

          expect(CachedPostsFinder.new(user, query: 'simpl').without_cache.map(&:id)).to(
            match_array [user_post_0.id, user_post_1.id, new_post.id]
          )
        end
      end
    end
  end

  context 'single' do
    let(:finder) { PostFinder.new(finder_user) }
    let(:finder_user) { user }
    describe '#cache_key' do
      it 'returns proper cache_key' do
        expect(finder.cache_key).to eq "post_finder/#{user.id}"
      end
    end

    describe '#call' do
      it 'finds record' do
        expect(finder.call).to eq user_post_0
      end
    end

    describe '#load' do
      it 'finds record' do
        expect(finder.load).to eq user_post_0
      end
    end
  end

  context 'will_paginate' do
    let(:finder) { PostsFinder.new(finder_user, per_page: 2, page: 1) }
    let(:query) { 'simpl' }
    let(:finder_user) { user }

    describe '#page' do
      it 'returns current_page' do
        expect(finder.current_page).to eq 1
      end
    end

    describe '#per_page' do
      it 'returns current per_page value' do
        expect(finder.per_page).to eq 2
      end
    end

    describe '#total_pages' do
      it 'returns total_pages' do
        expect(finder.total_pages).to eq 2
      end
    end

    describe '#total_entries' do
      it 'returns total_entries' do
        expect(finder.total_entries).to eq 3
      end
    end
  end
end

