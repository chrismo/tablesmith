# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tablesmith/version'

Gem::Specification.new do |gem|
  gem.name          = 'tablesmith'
  gem.version       = Tablesmith::VERSION
  gem.authors       = ['chrismo']
  gem.email         = ['chrismo@clabs.org']
  gem.description   = 'Minimal console table'
  gem.summary       = 'Minimal console table'
  gem.homepage      = 'http://github.com/livingsocial/tablesmith'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'text-table'

  gem.add_development_dependency 'activerecord', '~> 3.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake', '>= 12.3.3'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop_lineup'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'sqlite3', '~> 1.3.5'
end
