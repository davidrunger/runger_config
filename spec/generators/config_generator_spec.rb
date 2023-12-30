# frozen_string_literal: true

require 'generators/runger/config/config_generator'
require 'spec_helper'

describe Runger::Generators::ConfigGenerator, :rails, type: :generator do
  subject do
    run_generator(args)
    target_file
  end

  before(:all) { destination File.join(__dir__, '../../tmp/basic_rails_app') }

  let(:configs_root) { Runger::Settings.autoload_static_config_path }

  let(:args) { %w[api_service api_key secret mode --no-yml] }

  before do
    prepare_destination
    FileUtils.cp_r(
      File.join(__dir__, 'fixtures/basic_rails_app'),
      File.join(__dir__, '../../tmp'),
    )
  end

  describe 'config' do
    let(:target_file) { file("#{configs_root}/api_service_config.rb") }

    specify do
      expect(subject).to exist
      expect(subject).to contain(/class APIServiceConfig < ApplicationConfig/)
      expect(subject).to contain(/attr_config :api_key, :secret, :mode/)
    end

    context 'with --yml' do
      let(:target_file) { file('config/api_service.yml') }

      let(:args) { %w[api_service api_key secret mode --yml] }

      it 'creates a .yml file' do
        expect(subject).to exist
        expect(file("#{configs_root}/api_service_config.rb")).to exist
      end

      it 'is a valid YAML with env keys' do
        expect(subject).to exist

        data =
          begin
            YAML.load_file(subject, aliases: true)
          rescue
            YAML.load_file(subject)
          end

        expect(data.keys).to match_array(
          %w[default development test production],
        )
        expect(subject).to contain('#  api_key:')
        expect(subject).to contain('#  secret:')
        expect(subject).to contain('#  mode:')
      end
    end

    context 'with --app' do
      let(:target_file) { file('app/configs/api_service_config.rb') }

      let(:args) { %w[api_service api_key secret mode --app --no-yml] }

      it 'creates config in app/configs' do
        expect(subject).to exist
      end
    end

    context 'when autoload_static_config_path is set' do
      let(:target_file) { file('config/settings/api_service_config.rb') }

      before do
        allow(Runger::Settings).to receive(:autoload_static_config_path) { file('config/settings') }
      end

      it 'creates config in this path' do
        expect(subject).to exist
      end
    end

    context "when name doesn't contain underscores" do
      let(:target_file) { file("#{configs_root}/avz_config.rb") }

      let(:args) { %w[avz sacred_key continent --no-yml] }

      specify do
        expect(subject).to exist
        expect(subject).to contain(/class AvzConfig < ApplicationConfig/)
        expect(subject).to contain(/attr_config :sacred_key, :continent/)
        expect(subject).not_to contain(/config_name/)
      end
    end
  end
end
