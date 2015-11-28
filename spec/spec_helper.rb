require 'bundler/setup'
Bundler.setup

require 'hash_map_hash'

RSpec.configure do |config|
  config.color = true
  config.order = :random
  Kernel.srand config.seed
end
