# frozen_string_literal: true

require 'generators/runger/config/config_generator'

class Runger::Generators::AppConfigGenerator < ConfigGenerator
  source_root ConfigGenerator.source_root

  private

  def config_root
    'app/configs'
  end
end
