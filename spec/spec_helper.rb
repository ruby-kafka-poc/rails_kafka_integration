# frozen_string_literal: true

# Simplecov need to be first required
require 'simplecov_helper'
require 'kafka_rails_integration'

begin
  require 'debug'
rescue LoadError
  # debug is not activated.
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
