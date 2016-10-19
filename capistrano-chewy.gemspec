# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-chewy/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-chewy'
  spec.version       = CapistranoChewy.gem_version
  spec.authors       = ['Nikita Bulai']
  spec.date          = '2016-10-20'
  spec.email         = ['bulajnikita@gmail.com']
  spec.summary       = 'Manage and continuously rebuild your ElasticSearch indexes with Chewy and Capistrano'
  spec.description   = 'Manage and continuously rebuild your ElasticSearch indexes with Chewy and Capistrano v3.'
  spec.homepage      = 'https://github.com/nbulaj/capistrano-chewy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'capistrano', '~> 3.0'
  spec.add_dependency 'chewy', '~> 0.4'

  spec.add_development_dependency 'rspec', '~> 3.0'
end
