# frozen_string_literal: true

class Runger::Rails::Loaders::Secrets < Runger::Loaders::Base
  def call(name:, **_options)
    return {} unless ::Rails.application.respond_to?(:secrets)

    # Create a new hash cause secrets are mutable!
    config = {}

    trace!(:secrets) do
      secrets.public_send(name)
    end.then do |secrets|
      ::Runger::Utils.deep_merge!(config, secrets) if secrets
    end

    config
  end

  private

  def secrets
    @secrets ||=
      ::Rails.application.secrets.tap do |_|
        # Reset secrets state if the app hasn't been initialized
        # See https://github.com/palkan/runger_config/issues/14
        next if ::Rails.application.initialized?

        ::Rails.application.remove_instance_variable(:@secrets)
      end
  end
end
