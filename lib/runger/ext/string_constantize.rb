# frozen_string_literal: true

# Add simple safe_constantize method to String
module Runger::Ext::StringConstantize
  refine String do
    def safe_constantize
      names = split('::')

      if names.empty?
        nil
      else
        # Remove the first blank element in case of '::ClassName' notation.
        if names.size > 1 && names.first.empty?
          names.shift
        end

        names.inject(Object) do |constant, name|
          if constant.nil?
            break
          end

          if constant.const_defined?(name, false)
            constant.const_get(name, false)
          end
        end
      end
    end
  end
end
