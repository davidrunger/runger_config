# frozen_string_literal: true

# Load the Rails application
require_relative 'application'

# Initialize the Rails application.
unless ENV['DO_NOT_INITIALIZE_RAILS'] == '1'
  Dummy::Application.initialize!
end
