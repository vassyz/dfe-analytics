# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV['SUPPRESS_DFE_ANALYTICS_INIT'] = 'true'

require_relative '../spec/dummy/config/environment'
require 'debug'
require 'rspec/rails'
require 'webmock/rspec'
require 'json-schema'
require 'dfe/analytics/testing'
require 'dfe/analytics/testing/helpers'

require_relative '../spec/support/json_schema_validator'

if ::Rails::VERSION::MAJOR >= 7
  require 'active_support/testing/tagged_logging'

  RSpec::Core::ExampleGroup.module_eval do
    include ActiveSupport::Testing::TaggedLogging

    def name; end
  end
end

ActiveRecord::Migrator.migrations_paths = [File.expand_path('../spec/dummy/db/migrate', __dir__)]

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.use_transactional_fixtures = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.define_derived_metadata do |metadata|
    metadata[:suppress_init] = false unless metadata[:suppress_init] == true
  end

  config.around suppress_init: false do |example|
    DfE::Analytics.initialize!
    example.run
  end

  config.before do
    DfE::Analytics.instance_variable_set(:@events_client, nil)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  include DfE::Analytics::Testing::Helpers

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end
