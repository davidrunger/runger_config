# frozen_string_literal: true

module Runger
  module Rails
  end
end

require "runger/rails/settings"
require "runger/rails/config"
require "runger/rails/loaders"

# Configure Rails loaders
Runger.loaders.override :yml, Runger::Rails::Loaders::YAML

if Rails::VERSION::MAJOR >= 7 && Rails::VERSION::MINOR >= 1
  Runger.loaders.insert_after :yml, :credentials, Runger::Rails::Loaders::Credentials
else
  Runger.loaders.insert_after :yml, :secrets, Runger::Rails::Loaders::Secrets
  Runger.loaders.insert_after :secrets, :credentials, Runger::Rails::Loaders::Credentials
end

# Load Railties after configuring loaders.
# The application could be already initialized, and that would make `Runger.loaders` frozen
require "runger/railtie"
