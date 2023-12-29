# frozen_string_literal: true

class Runger::Loaders::Env < Base
  def call(env_prefix:, **_options)
    env = ::Runger::Env.new(type_cast: ::Runger::NoCast)

    env.fetch_with_trace(env_prefix).then do |(conf, trace)|
      Tracing.current_trace&.merge!(trace)
      conf
    end
  end
end
