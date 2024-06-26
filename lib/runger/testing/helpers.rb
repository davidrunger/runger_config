# frozen_string_literal: true

module Runger::Testing::Helpers
  # Sets the ENV variables to the provided
  # values and restore outside the block
  #
  # Also resets Runger.env before and after calling the block
  # to make sure that the values are not cached.
  #
  # NOTE: to remove the env value, pass `nil` as the value
  def with_env(data)
    was_values = []

    data.each do |key, val|
      was_values << [key, ENV.fetch(key, nil)]
      next ENV.delete(key) if val.nil?

      ENV[key] = val
    end

    # clear cached env values
    Runger.env.clear
    yield
  ensure
    was_values.each do |(key, val)|
      next ENV.delete(key) if val.nil?

      ENV[key] = val
    end

    # clear cache again
    Runger.env.clear
  end
end
