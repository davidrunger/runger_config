# frozen_string_literal: true

class CoolConfig < Runger::Config # :nodoc:
  config_name :cool
  attr_config :meta,
    :data,
    port: 8080,
    host: 'localhost',
    user: { name: 'admin', password: 'admin' }.stringify_keys

  coerce_types host: :string, user: { dob: :date }
end
