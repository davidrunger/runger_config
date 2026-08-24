# frozen_string_literal: true

module Runger::Utils
  # Cross-platform solution
  # taken from https://stackoverflow.com/a/5471032
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        if File.executable?(exe) && !File.directory?(exe)
          return exe
        end
      end
    end
    nil
  end
end
