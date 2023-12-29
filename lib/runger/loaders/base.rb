# frozen_string_literal: true

module Runger
  module Loaders
    class Base
      include Tracing

      class << self
        def call(local: Runger::Settings.use_local_files, **options)
          new(local:).call(**options)
        end
      end

      def initialize(local:)
        @local = local
      end

      def use_local? = @local == true
    end
  end
end
