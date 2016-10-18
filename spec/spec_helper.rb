require 'bundler/setup'
Bundler.setup

require 'capistrano-chewy'

RSpec.configure do |config|
  config.order = 'random'
end
