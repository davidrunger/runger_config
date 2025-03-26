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

    return base_config unless use_local?

    local_path = local_config_path(config_path)
    local_config =
      trace!(:yml, path: relative_config_path(local_path).to_s) do
        load_local_yml(local_path)
      end
    ::Runger::Utils.deep_merge!(base_config, local_config)
  end

  private

  def environmental?(parsed_yml)
    # strange, but still possible
    return true if ::Runger::Settings.default_environmental_key? && parsed_yml.key?(::Runger::Settings.default_environmental_key)
    # possible
    return true if !::Runger::Settings.future.unwrap_known_environments && ::Runger::Settings.current_environment
    # for other environments
    return true if ::Runger::Settings.known_environments&.any? { parsed_yml.key?(it) }

    # preferred
    parsed_yml.key?(::Runger::Settings.current_environment)
  end

  def config_with_env(config)
    env_config = config[::Runger::Settings.current_environment] || {}
    return env_config unless ::Runger::Settings.default_environmental_key?

    default_config = config[::Runger::Settings.default_environmental_key] || {}
    ::Runger::Utils.deep_merge!(default_config, env_config)
  end

  def parse_yml(path)
    return {} unless File.file?(path)

    require 'yaml' unless defined?(::YAML)

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
  end

  alias load_base_yml parse_yml
  alias load_local_yml parse_yml

  def local_config_path(path)
    path.sub('.yml', '.local.yml')
  end

  def relative_config_path(path)
    Pathname.new(path).then do |path|
      return path if path.relative?

      path.relative_path_from(::Runger::Settings.app_root)
    end
  end
end
