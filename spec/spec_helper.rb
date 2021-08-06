require 'bundler/setup'
require 'simplecov'
SimpleCov.start 'rails' do
  minimum_coverage 99

  add_filter 'findit/version'
end

require 'findit'

require 'combustion'
require 'will_paginate'
require 'pry-byebug'

require 'active_record'

Combustion.initialize! :active_record do
  config.cache_store = :memory_store
end

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    Rails.cache.clear
    example.run
    ActionController::Base.perform_caching = caching
  end
end
