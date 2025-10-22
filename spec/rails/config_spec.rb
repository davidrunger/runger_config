# frozen_string_literal: true

require 'spec_helper'

describe Runger::Config, :rails, type: :config do
  let(:conf) { CoolConfig.new }

  describe 'load_from_sources in Rails' do
    it 'set defaults' do
      expect(conf.port).to eq(8080)
    end

    it 'load config from YAML' do
      expect(conf.host).to eq('test.host')
    end

    it 'sets overrides after loading YAML' do
      config = CoolConfig.new(host: 'overrided.host')
      expect(config.host).to eq('overrided.host')
    end

    if NORAILS
      it 'load config from file if no secrets' do
        expect(conf.user[:name]).to eq('root')
        expect(conf.user[:password]).to eq('root')
      end
    elsif Rails.application.respond_to?(:credentials)
      it 'load config from secrets and credentials' do
        expect(conf.user[:name]).to eq('secret man')
        expect(conf.meta).to eq('kot' => 'leta')
        expect(conf.user[:password]).to eq('root')
      end

      it 'sets overrides after loading secrets' do
        config = CoolConfig.new(user: { 'password' => 'override' })
        expect(config.user[:name]).to eq('secret man')
        expect(config.user[:password]).to eq('override')
      end

      context 'when using local files' do
        around do |ex|
          Runger::Settings.use_local_files = true
          ex.run
          Runger::Settings.use_local_files = false
        end

        it 'load config local credentials too' do
          expect(conf.user[:name]).to eq('secret man')
          unless NOSECRETS
            expect(conf.meta).to eq('kot' => 'murkot')
          end
          expect(conf.user[:password]).to eq('password')
        end
      end

      specify '#to_source_trace' do
        # Rails 5 doesn't have credentials config
        credentials_path =
          if Rails.application.config.respond_to?(:credentials)
            'config/credentials/test.yml.enc'
          else
            'config/credentials.yml.enc'
          end

        with_env(
          'COOL_USER__PASSWORD' => 'secret',
        ) do
          expect(conf).to have_valid_trace
          expect(conf.to_source_trace).to eq(
            {
              'host' => {
                value: 'test.host',
                source: { type: :yml, path: 'config/cool.yml' },
              },
              'user' => {
                'name' => {
                  value: 'secret man',
                  source: { type: :credentials, store: credentials_path },
                },
                'password' => {
                  value: 'secret',
                  source: { type: :env, key: 'COOL_USER__PASSWORD' },
                },
              },
              'port' => { value: 8080, source: { type: :defaults } },
              'meta' => {
                'kot' => {
                  value: 'leta',
                  source: if NOSECRETS
                            {
                              type: :env,
                              key: 'COOL_META__KOT',
                            }
                          else
                            { type: :secrets }
                          end,
                },
              },
            },
          )
        end
      end
    else
      it 'load config from secrets' do
        expect(conf.user[:name]).to eq('test')
        expect(conf.meta).to eq('kot' => 'leta')
        expect(conf.user[:password]).to eq('root')
      end

      it 'sets overrides after loading secrets' do
        config = CoolConfig.new(user: { 'password' => 'override' })
        expect(config.user[:name]).to eq('root')
        expect(config.user[:password]).to eq('override')
      end
    end
  end

  context 'validation' do
    specify do
      expect { MyAppConfig.new }.
        to raise_error(Runger::Config::ValidationError, /missing or empty: name, mode/)
    end
  end
end
