# frozen_string_literal: true

require File.expand_path('../lib/tablesmith', __dir__)

require File.expand_path('fixtures', __dir__)

RSpec.configuration.expect_with(:rspec) { |c| c.syntax = :should }
