# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tablesmith/version'

Gem::Specification.new do |gem|
  gem.name          = 'tablesmith'
  gem.version       = Tablesmith::VERSION
  gem.authors       = ['chrismo']
  gem.email         = ['chrismo@clabs.org']
  gem.description   = %q{Minimal console table}
  gem.summary       = %q{Minimal console table}
  gem.homepage      = 'http://github.com/livingsocial/tablesmith'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'text-table'

  gem.add_development_dependency 'activerecord', '~> 3.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 2.0'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'sqlite3'
end
