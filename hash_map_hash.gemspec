Gem::Specification.new do |s|
  s.name        = 'hash_map_hash'
  s.version     = '1.0.3'
  s.date        = Date.today
  s.summary     = 'Convert hash to hash using hash map'
  s.description = 'Flatten deeply nested hash and convert keys'
  s.authors     = ['Denis Peplin']
  s.email       = 'denis.peplin@gmail.com'
  s.files       = ['lib/hash_map_hash.rb']
  s.homepage    = 'http://github.com/7Pikes/hash_map_hash'
  s.license     = 'MIT'

  s.required_ruby_version = '~> 2.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
