require 'bundler/setup'
require 'simplecov'
SimpleCov.start 'rails' do
  minimum_coverage 90

  add_filter 'findit/version'
end

require 'findit'
require 'rails'
require 'rails-cache-tags'
require 'will_paginate'

require 'combustion'

Combustion.initialize! :all

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
