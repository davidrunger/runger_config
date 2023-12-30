# frozen_string_literal: true

require 'runger/version'

module Runger ; end
module Runger::Ext ; end

require 'runger/ext/deep_dup'
require 'runger/ext/deep_freeze'
require 'runger/ext/flatten_names'
require 'runger/ext/hash'

require 'runger/utils/deep_merge'
require 'runger/utils/which'

require 'runger/auto_cast'
require 'runger/config'
require 'runger/env'
require 'runger/loaders'
require 'runger/rbs'
require 'runger/settings'
require 'runger/tracing'
require 'runger/type_casting'

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
  loaders.append(:yml, Loaders::YAML)
  loaders.append(:ejson, Loaders::EJSON) if Utils.which('ejson')
  loaders.append(:env, Loaders::Env)

  if ENV.key?('DOPPLER_TOKEN') && ENV['RUNGER_CONFIG_DISABLE_DOPPLER'] != 'true'
    loaders.append(:doppler, Loaders::Doppler)
  end
end

if defined?(Rails::VERSION)
  require 'runger/rails'
else
  require 'runger/rails/autoload'
end

require 'runger/testing' if ENV['RACK_ENV'] == 'test' || ENV['RAILS_ENV'] == 'test'
