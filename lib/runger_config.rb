# frozen_string_literal: true

require "runger/version"

require "runger/ext/deep_dup"
require "runger/ext/deep_freeze"
require "runger/ext/hash"
require "runger/ext/flatten_names"

require "runger/utils/deep_merge"
require "runger/utils/which"

require "runger/settings"
require "runger/tracing"
require "runger/config"
require "runger/auto_cast"
require "runger/type_casting"
require "runger/env"
require "runger/loaders"
require "runger/rbs"

module Runger # :nodoc:
  class << self
    def env
      @env ||= ::Runger::Env.new
    end

    def loaders
      @loaders ||= ::Runger::Loaders::Registry.new
    end
  end

  # Configure default loaders
  loaders.append :yml, Loaders::YAML
  loaders.append :ejson, Loaders::EJSON if Utils.which("ejson")
  loaders.append :env, Loaders::Env

  if ENV.key?("DOPPLER_TOKEN") && ENV["ANYWAY_CONFIG_DISABLE_DOPPLER"] != "true"
    loaders.append :doppler, Loaders::Doppler
  end
end

if defined?(::Rails::VERSION)
  require "runger/rails"
else
  require "runger/rails/autoload"
end

require "runger/testing" if ENV["RACK_ENV"] == "test" || ENV["RAILS_ENV"] == "test"
