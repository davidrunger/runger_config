# frozen_string_literal: true

require 'open3'
require 'runger/ext/hash'

using Runger::Ext::Hash

class Runger::EJSONParser
  attr_reader :bin_path

  def initialize(bin_path = 'ejson')
    @bin_path = bin_path
  end

  def call(file_path)
    if File.exist?(file_path)
      raw_content = nil

      stdout, stderr, status = Open3.capture3("#{bin_path} decrypt #{file_path}")

      if status.success?
        raw_content = JSON.parse(stdout.chomp)
      else
        Kernel.warn("Failed to decrypt #{file_path}: #{stderr}")
      end

      raw_content&.deep_transform_keys do |key|
        if key[0] == '_'
          # rubocop:disable-next Performance/ArraySemiInfiniteRangeSlice
          key[1..]
        else
          key
        end
      end
    end
  end
end
