# frozen_string_literal: true

if ENV['VERIFY_RESERVED'] == '1'
  called_methods = Set.new
end
if called_methods
  lib_path = File.realpath(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
end

if called_methods
  TracePoint.new(:call) do |ev|
    # already tracked
    if called_methods.include?(ev.method_id)
      next
    end
    # the event could be triggered before we load Runger::Config
    unless defined?(Runger::Config)
      next
    end
    # filter out methods called not on Config instances
    unless ev.self.is_a?(Runger::Config)
      next
    end
    # select only methods defined by the library, not user
    unless ev.defined_class == Runger::Config || Runger::Config.included_modules.include?(ev.defined_class)
      next
    end
    # make sure the method is called from the library code, not tests
    unless ev.binding.eval('caller').any? { |path| path.start_with?(lib_path) }
      next
    end

    called_methods << ev.method_id
  end.enable
end

RSpec.configure do |config|
  config.after(:suite) do
    unless called_methods
      next
    end

    called_methods = called_methods.to_a.grep(Runger::Config::PARAM_NAME)

    if (called_methods - Runger::Config::RESERVED_NAMES).empty?
      next puts("\nRunger::Config::RESERVED is OK") # rubocop:disable RSpec/Output
    end

    raise "Runger::Config::RESERVED is invalid.\n" \
          "Expected to contain: #{called_methods.sort}.\n" \
          "Contains: #{Runger::Config::RESERVED_NAMES.sort}.\n" \
          "Missing elements: #{(called_methods - Runger::Config::RESERVED_NAMES).sort}"
  end
end
