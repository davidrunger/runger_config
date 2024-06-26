# frozen_string_literal: true

return unless ENV['VERIFY_RESERVED'] == '1'

called_methods = Set.new
lib_path = File.realpath(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

TracePoint.new(:call) do |ev|
  # already tracked
  next if called_methods.include?(ev.method_id)
  # the event could be triggered before we load Runger::Config
  next unless defined?(Runger::Config)
  # filter out methods called not on Config instances
  next unless ev.self.is_a?(Runger::Config)
  # select only methods defined by the library, not user
  next unless ev.defined_class == Runger::Config || Runger::Config.included_modules.include?(ev.defined_class)
  # make sure the method is called from the library code, not tests
  next unless ev.binding.eval('caller').any? { |path| path.start_with?(lib_path) }

  called_methods << ev.method_id
end.enable

RSpec.configure do |config|
  config.after(:suite) do
    called_methods = called_methods.to_a.grep(Runger::Config::PARAM_NAME)

    if (called_methods - Runger::Config::RESERVED_NAMES).empty?
      next puts "\nRunger::Config::RESERVED is OK"
    end

    raise "Runger::Config::RESERVED is invalid.\n" \
          "Expected to contain: #{called_methods.sort}.\n" \
          "Contains: #{Runger::Config::RESERVED_NAMES.sort}.\n" \
          "Missing elements: #{(called_methods - Runger::Config::RESERVED_NAMES).sort}"
  end
end
