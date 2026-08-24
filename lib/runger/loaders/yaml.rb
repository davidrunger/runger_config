# frozen_string_literal: true

require 'pathname'
require 'runger/ext/hash'

using Runger::Ext::Hash

class Runger::Loaders::YAML < Runger::Loaders::Base
  def call(config_path:, **_options)
    rel_config_path = relative_config_path(config_path).to_s
    base_config =
      trace!(:yml, path: rel_config_path) do
        config = load_base_yml(config_path)
        environmental?(config) ? config_with_env(config) : config
      end

    if use_local?
      local_path = local_config_path(config_path)
      local_config =
        trace!(:yml, path: relative_config_path(local_path).to_s) do
          load_local_yml(local_path)
        end
      ::Runger::Utils.deep_merge!(base_config, local_config)
    else
      base_config
    end
  end

  private

  def environmental?(parsed_yml)
    # strange, but still possible
    environmental_key_present =
      (::Runger::Settings.default_environmental_key? && parsed_yml.key?(::Runger::Settings.default_environmental_key)) ||
      (!::Runger::Settings.future.unwrap_known_environments && ::Runger::Settings.current_environment) ||
      ::Runger::Settings.known_environments&.any? { parsed_yml.key?(it) }

    if environmental_key_present
      true
    else
      # preferred
      parsed_yml.key?(::Runger::Settings.current_environment)
    end
  end

  def config_with_env(config)
    env_config = config[::Runger::Settings.current_environment] || {}
    if ::Runger::Settings.default_environmental_key?
      default_config = config[::Runger::Settings.default_environmental_key] || {}
      ::Runger::Utils.deep_merge!(default_config, env_config)
    else
      env_config
    end
  end

  def parse_yml(path)
    if File.file?(path)
      unless defined?(::YAML)
        require 'yaml'
      end

      # By default, YAML load will return `false` when the yaml document is
      # empty. When this occurs, we return an empty hash instead, to match
      # the interface when no config file is present.
      begin
        if defined?(ERB)
          ::YAML.load(ERB.new(File.read(path)).result, aliases: true) || {}
        else
          ::YAML.load_file(path, aliases: true) || {}
        end
      rescue ArgumentError
        if defined?(ERB)
          ::YAML.load(ERB.new(File.read(path)).result) || {}
        else
          ::YAML.load_file(path) || {}
        end
      end
    else
      {}
    end
  end

  alias load_base_yml parse_yml
  alias load_local_yml parse_yml

  def local_config_path(path)
    path.sub('.yml', '.local.yml')
  end

  def relative_config_path(path)
    path = Pathname.new(path)
    if path.relative?
      path
    else
      path.relative_path_from(::Runger::Settings.app_root)
    end
  end
end
