# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

FileList['tasks/*.rake'].each(&method(:load))

task default: :spec

desc 'Run the specs.'
RSpec::Core::RakeTask.new do |t|
  t.pattern = '*_spec.rb'
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)

task default: :rubocop
