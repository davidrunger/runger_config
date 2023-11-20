# frozen_string_literal: true

require "generators/runger/config/config_generator"

module Runger
  module Generators
    class AppConfigGenerator < ConfigGenerator
      source_root ConfigGenerator.source_root

      private

      def config_root
        "app/configs"
      end
    end
  end
end
