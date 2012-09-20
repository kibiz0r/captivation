require 'bundler'
Bundler.require :default, :test
require 'rspec'

RSpec.configure do |config|
  config.mock_with :rr
end

