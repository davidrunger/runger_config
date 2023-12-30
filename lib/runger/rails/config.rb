# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module Runger::Rails::Config ; end

# Enhance config to be more Railsy-like:
# – accept hashes with indeferent access
# - load data from secrets
# - recognize Rails env when loading from YML
module Runger::Rails::Config::ClassMethods
  # Make defaults to be a Hash with indifferent access
  def new_empty_config
    {}.with_indifferent_access
  end
end

Runger::Config.prepend(Runger::Rails::Config)
Runger::Config.singleton_class.prepend(Runger::Rails::Config::ClassMethods)
