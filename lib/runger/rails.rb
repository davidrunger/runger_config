# frozen_string_literal: true

module Runger
  module Rails
  end
end

require "anyway/rails/settings"
require "anyway/rails/config"
require "anyway/rails/loaders"

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
require "anyway/railtie"
