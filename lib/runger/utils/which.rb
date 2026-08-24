# frozen_string_literal: true

module Runger::Utils
  # Cross-platform solution
  # taken from https://stackoverflow.com/a/5471032
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).product(exts).lazy.map do |path, ext|
      File.join(path, "#{cmd}#{ext}")
    end.find { |exe| File.executable?(exe) && !File.directory?(exe) }
  end
end
