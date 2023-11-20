# frozen_string_literal: true

class LoadConfig < Runger::Config
  attr_config :revision
end

# Custom loader
class CustomConfigLoader < Runger::Loaders::Base
  def call(name:, **_opts)
    trace!(:custom) do
      {revision: "ab34fg"}
    end
  end
end

Runger.loaders.insert_after :env, :custom, CustomConfigLoader

LoadConfig.new.revision == "ab34fg" or raise "Something went wrong"
