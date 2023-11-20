# frozen_string_literal: true

class ApplicationConfig < Runger::Config
  class << self
    def instance
      @instance ||= new
    end
  end
end
