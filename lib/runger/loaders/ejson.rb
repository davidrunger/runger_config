# frozen_string_literal: true

require 'runger/ejson_parser'

class Runger::Loaders::EJSON < Runger::Loaders::Base
  class << self
    attr_accessor :bin_path
  end

  self.bin_path = 'ejson'

  def call(
    name:,
    ejson_namespace: name,
    ejson_parser: Runger::EJSONParser.new(Runger::Loaders::EJSON.bin_path),
    **_options
  )
    configs = []

    rel_config_paths.each do |rel_config_path|
      secrets_hash, rel_path =
        extract_hash_from_rel_config_path(
          ejson_parser:,
          rel_config_path:,
        )

      unless secrets_hash
        next
      end

      config_hash =
        if ejson_namespace
          secrets_hash[ejson_namespace]
        else
          secrets_hash.except('_public_key')
        end

      unless config_hash.is_a?(Hash)
        next
      end

      configs <<
        trace!(:ejson, path: rel_path) do
          config_hash
        end
    end

    if configs.empty?
      return {}
    end

    configs.inject do |result_config, next_config|
      ::Runger::Utils.deep_merge!(result_config, next_config)
    end
  end

  private

  def rel_config_paths
    chain = [environmental_rel_config_path]

    if use_local?
      chain << 'secrets.local.ejson'
    end

    chain
  end

  def environmental_rel_config_path
    if ::Runger::Settings.current_environment
      # if environment file is absent, then take data from the default one
      [
        "#{::Runger::Settings.current_environment}/secrets.ejson",
        default_rel_config_path,
      ]
    else
      default_rel_config_path
    end
  end

  def default_rel_config_path
    'secrets.ejson'
  end

  def extract_hash_from_rel_config_path(ejson_parser:, rel_config_path:)
    rel_config_path = Array(rel_config_path)

    rel_config_path.each do |rel_conf_path|
      rel_path = "config/#{rel_conf_path}"
      abs_path = "#{::Runger::Settings.app_root}/#{rel_path}"

      result = ejson_parser.call(abs_path)

      if result
        return [result, rel_path]
      end
    end

    nil
  end
end
