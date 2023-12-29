# frozen_string_literal: true

require 'generators/runger/install/install_generator'
require 'spec_helper'

describe Runger::Generators::InstallGenerator, :rails, type: :generator do
  subject do
    run_generator(args)
    target_file
  end

  before(:all) { destination File.join(__dir__, '../../tmp/basic_rails_app') }

  let(:configs_root) { Runger::Settings.autoload_static_config_path }
  let(:args) { [] }

  before do
    prepare_destination
    FileUtils.cp_r(
      File.join(__dir__, 'fixtures/basic_rails_app'),
      File.join(__dir__, '../../tmp'),
    )
  end

  describe 'application config' do
    let(:target_file) { file("#{configs_root}/application_config.rb") }

    specify do
      expect(subject).to exist
      expect(subject).to contain(/class ApplicationConfig < Runger::Config/)
      expect(subject).to contain(/delegate_missing_to :instance/)
      expect(subject).to contain(/def instance/)
    end

    context 'config/application.rb' do
      let(:target_file) { file('config/application.rb') }

      it 'contains autoload_static_config_path' do
        expect(subject).to exist
        expect(subject).to contain("    # config.runger_config.autoload_static_config_path = \"#{configs_root}\"\n    #\n")
      end

      context 'with --configs-path' do
        let(:args) { %w[--configs-path=config/settings] }

        it 'configures autoload_static_config_path' do
          expect(subject).to exist
          expect(subject).to contain("    config.runger_config.autoload_static_config_path = \"config/settings\"\n\n")

          expect(file('config/settings/application_config.rb')).to exist
        end
      end
    end

    describe '.gitignore' do
      let(:target_file) { file('.gitignore') }

      specify do
        expect(subject).to exist
        expect(subject).to contain('/config/*.local.yml')
        expect(subject).to contain('/config/credentials/local.*')
      end
    end

    context 'when autoload_static_config_path is set' do
      let(:target_file) { file('config/settings/application_config.rb') }

      before {
        allow(Runger::Settings).to receive(:autoload_static_config_path) {
                                     file('config/settings')
                                   }
      }

      it 'creates application config in this path' do
        expect(subject).to exist
      end
    end
  end
end
