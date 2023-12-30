# frozen_string_literal: true

require 'generators/runger/app_config/app_config_generator'
require 'spec_helper'

describe Runger::Generators::AppConfigGenerator, :rails, type: :generator do
  subject do
    run_generator(args)
    target_file
  end

  before(:all) { destination File.join(__dir__, '../../tmp/basic_rails_app') }

  let(:args) { %w[api_service api_key secret mode --no-yml] }

  before do
    prepare_destination
    FileUtils.cp_r(
      File.join(__dir__, 'fixtures/basic_rails_app'),
      File.join(__dir__, '../../tmp'),
    )
  end

  describe 'config' do
    let(:target_file) { file('app/configs/api_service_config.rb') }

    specify do
      expect(subject).to exist
      expect(subject).to contain(/class APIServiceConfig < ApplicationConfig/)
      expect(subject).to contain(/attr_config :api_key, :secret, :mode/)
    end
  end
end
