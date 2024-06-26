# frozen_string_literal: true

# Add simple safe_constantize method to String
module Runger::Ext::StringConstantize
  refine String do
    def safe_constantize
      names = split('::')

      return nil if names.empty?

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        break if constant.nil?

        constant.const_get(name, false) if constant.const_defined?(name, false)
      end
    end
  end
end
