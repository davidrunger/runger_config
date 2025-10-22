# frozen_string_literal: true

begin
  require 'debug' unless ENV['CI']
rescue LoadError
end

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

NORAILS = ENV['NORAILS'] == '1'

begin
  if NORAILS
    ENV['RACK_ENV'] = 'test'

    require 'runger_config'

    Runger::Settings.use_local_files = false
  else
    ENV['RAILS_ENV'] = 'test'

    # Load runger_config before Rails to test that we can detect Rails app before it's loaded
    require 'runger_config' unless defined?(TruffleRuby)

    require 'ammeter'

    require File.expand_path('dummy/config/environment', __dir__)
  end
rescue => err
  $stdout.puts "Failed to load test env: #{err}\n#{err.backtrace.take(5).join("\n")}"
  exit(1)
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

NOSECRETS = !NORAILS && Gem::Version.new(Rails.version) >= Gem::Version.new('7.1.0')

RSpec.configure do |config|
  config.mock_with(:rspec)

  config.filter_run_excluding(rails: true) if NORAILS
  config.filter_run_excluding(norails: true) unless NORAILS
  # Igonore specs manually checking for argument types when running RBS runtime tester
  config.filter_run_excluding(rbs: false) if defined?(RBS::Test)

  config.example_status_persistence_file_path = 'tmp/rspec_examples.txt'
  config.filter_run(:focus)
  config.run_all_when_everything_filtered = true

  if NOSECRETS
    config.around(:each, type: :config) do |ex|
      with_env('COOL_META__KOT' => 'leta', &ex)
    end
  end

  config.order = :random
  Kernel.srand(config.seed)
end
