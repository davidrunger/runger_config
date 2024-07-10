# frozen_string_literal: true

require_relative 'lib/runger/version'

Gem::Specification.new do |spec|
  spec.name = 'runger_config'
  spec.version = Runger::VERSION
  spec.authors = ['David Runger']
  spec.email = ['davidjrunger@gmail.com']
  spec.homepage = 'http://github.com/davidrunger/runger_config'
  spec.summary = 'Configuration DSL for Ruby libraries and applications'
  spec.description = %{
    Configuration DSL for Ruby libraries and applications.
    Allows you to easily follow the twelve-factor application principles (https://12factor.net/config).
  }

  spec.metadata = {
    'bug_tracker_uri' => 'http://github.com/davidrunger/runger_config/issues',
    'changelog_uri' => 'https://github.com/davidrunger/runger_config/blob/main/CHANGELOG.md',
    'documentation_uri' => 'http://github.com/davidrunger/runger_config',
    'funding_uri' => 'https://github.com/sponsors/davidrunger',
    'homepage_uri' => 'http://github.com/davidrunger/runger_config',
    'source_code_uri' => 'http://github.com/davidrunger/runger_config',
    'rubygems_mfa_required' => 'true',
  }

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.license = 'MIT'

  spec.files = Dir.glob('lib/**/*') +
    Dir.glob('bin/**/*') + %w[sig/runger_config.rbs sig/manifest.yml] +
    %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ['lib']
  required_ruby_version = File.read('.ruby-version').rstrip.sub(/\A(\d+\.\d+)\.\d+\z/, '\1.0')
  spec.required_ruby_version = ">= #{required_ruby_version}"

  spec.add_runtime_dependency('activesupport', '>= 7.1.2')
end
