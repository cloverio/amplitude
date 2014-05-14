require 'codeclimate-test-reporter'
require_relative '../lib/amplitude'

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

CodeClimate::TestReporter.start
