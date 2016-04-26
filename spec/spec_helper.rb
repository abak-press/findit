require 'bundler/setup'
require 'simplecov'
SimpleCov.start 'rails' do
  minimum_coverage 93

  add_filter 'findit/version'
end

require 'findit'

require 'combustion'

Combustion.initialize! :all

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
