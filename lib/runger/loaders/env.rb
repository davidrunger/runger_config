# frozen_string_literal: true

class Runger::Loaders::Env < Runger::Loaders::Base
  def call(env_prefix:, **_options)
    env = ::Runger::Env.new(type_cast: ::Runger::NoCast)

    env.fetch_with_trace(env_prefix).then do |(conf, trace)|
      ::Runger::Tracing.current_trace&.merge!(trace)
      conf
    end
  end
end
