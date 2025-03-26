# frozen_string_literal: true

ruby file: '.ruby-version'

source 'https://rubygems.org'

group :development, :test do
  gem 'ammeter'
  gem 'ejson'
  gem 'pry-byebug', require: false, github: 'davidrunger/pry-byebug'
  gem 'rake'
  gem 'rubocop'
  gem 'rubocop-md'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'runger_style', require: false
end

group :development do
  gem 'runger_release_assistant', require: false
end

group :test do
  gem 'rspec'
  gem 'webmock'
end

gemspec

eval_gemfile 'gemfiles/rbs.gemfile'

local_gemfile = "#{File.dirname(__FILE__)}/Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
else
  gem 'rails', '~> 8.0'
end
