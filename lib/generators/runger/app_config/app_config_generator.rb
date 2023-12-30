# frozen_string_literal: true

require 'generators/runger/config/config_generator'

class Runger::Generators::AppConfigGenerator < Runger::Generators::ConfigGenerator
  source_root ::Runger::Generators::ConfigGenerator.source_root

  private

  def config_root
    'app/configs'
  end
end
