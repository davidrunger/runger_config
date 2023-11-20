# frozen_string_literal: true

require "runger/testing/helpers"

if defined?(RSpec::Core) && RSpec.respond_to?(:configure)
  RSpec.configure do |config|
    config.include(
      Runger::Testing::Helpers,
      type: :config,
      file_path: %r{spec/configs}
    )
  end
end
