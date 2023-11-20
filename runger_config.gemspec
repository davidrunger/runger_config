# frozen_string_literal: true

require_relative "lib/anyway/version"

Gem::Specification.new do |s|
  s.name = "runger_config"
  s.version = Runger::VERSION
  s.authors = ["David Runger"]
  s.email = ["davidjrunger@gmail.com"]
  s.homepage = "http://github.com/davidrunger/runger_config"
  s.summary = "Configuration DSL for Ruby libraries and applications"
  s.description = %{
    Configuration DSL for Ruby libraries and applications.
    Allows you to easily follow the twelve-factor application principles (https://12factor.net/config).
  }

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/davidrunger/runger_config/issues",
    "changelog_uri" => "https://github.com/davidrunger/runger_config/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/davidrunger/runger_config",
    "funding_uri" => "https://github.com/sponsors/davidrunger",
    "homepage_uri" => "http://github.com/davidrunger/runger_config",
    "source_code_uri" => "http://github.com/davidrunger/runger_config"
  }

  s.metadata.merge!({
    "rubygems_mfa_required" => "true"
  })

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") +
    Dir.glob("bin/**/*") + %w[sig/anyway_config.rbs sig/manifest.yml] +
    %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.2.2"

  s.add_runtime_dependency "activesupport", ">= 7.1.2"

  s.add_development_dependency "ammeter", "~> 1.1.3"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "rspec", ">= 3.8"
  s.add_development_dependency "webmock", "~> 3.18"
  s.add_development_dependency "ejson", ">= 1.3.1"
end
