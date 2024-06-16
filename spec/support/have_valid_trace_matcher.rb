# frozen_string_literal: true

using Runger::Ext::Hash

RSpec::Matchers.define(:have_valid_trace) do
  match do |conf|
    @values = conf.send(:values).stringify_keys!
    @trace = extract_value(conf.send(:__trace__))
    # Trace collects keys not present in the attr_config
    @trace.keep_if { |k, _v| @values.key?(k) }
    @trace == @values
  end

  failure_message do
    # rubocop:disable Layout/LineEndStringConcatenationIndentation
    "config trace is invalid:\n " \
      "- trace: #{@trace}\n " \
      "- config: #{@values}"
    # rubocop:enable Layout/LineEndStringConcatenationIndentation
  end

  def extract_value(val)
    if val.trace?
      val.value.transform_values { |v| extract_value(v) }
    else
      val.value
    end
  end
end
