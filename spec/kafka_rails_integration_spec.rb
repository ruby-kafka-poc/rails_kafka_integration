# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KafkaRailsIntegration do
  let(:default_config) do
    {
      bootstrap_servers: 'localhost:9092',
      request_required_acks: 1,
      security_protocol: nil,
      sasl_mechanism: nil,
      sasl_username: nil,
      sasl_password: nil
    }
  end
  let(:rails) { double('Rails') }
  let(:logger) { double('Logger') }

  before do
    stub_const('Rails', rails)
    allow(rails).to receive(:env).and_return('test')
    allow(rails).to receive(:application).and_return(double('Application'))
    allow(rails).to receive(:logger).and_return(logger)
    allow(rails.application).to receive(:class).and_return(double('class'))
    allow(rails.application.class).to receive(:module_parent_name).and_return('TestingMe')
    allow(logger).to receive(:warn)
  end

  # SimpleCov lose the track before { load('./lib/kafka_rails_integration.rb') }
  after do
    KafkaRailsIntegration.instance_variable_set('@topics', [])
    KafkaRailsIntegration.instance_variable_set('@config', default_config)
    KafkaRailsIntegration.instance_variable_set("@logger", nil)
  end

  it 'has a version number' do
    expect(KafkaRailsIntegration::VERSION).not_to be_nil
    end

  it 'has a client id' do
    expect(KafkaRailsIntegration.client_id).to eq('TestingMe')
  end

  context '#configure' do
    let(:expected_config) do
      {
        bootstrap_servers: 'localhost:9092',
        request_required_acks: 5,
        security_protocol: nil,
        sasl_mechanism: nil,
        sasl_username: nil,
        sasl_password: nil,
        client_id: 'COOOL'
      }
    end

    context 'without topics' do
      before { KafkaRailsIntegration.configure(request_required_acks: 5) }

      it 'configure with key value pair ops' do
        expect(KafkaRailsIntegration.config).to eq(expected_config.except(:client_id))
      end

      it 'has a client id' do
        expect(KafkaRailsIntegration.client_id).to eq('TestingMe')
      end
    end

    context 'with topics' do
      let(:topics) { %w[some cool topics] }

      before do
        # allow_any_instance_of(Kafka::Client).to receive(:create_topic)
        topics.each do |topic|
          expect_any_instance_of(Kafka::Client).to receive(:create_topic)
            .with(topic, {
                    num_partitions: 1,
                    replication_factor: 3
                  })
        end
        KafkaRailsIntegration.configure(topics:)
      end

      it 'configure with key value pair ops' do
        expect(KafkaRailsIntegration.topics).to eq(topics)
      end
    end

    context 'with file' do
      let(:topics) { %w[some topic] }

      before do
        topics.each do |topic|
          expect_any_instance_of(Kafka::Client).to receive(:create_topic)
            .with(topic, {
                    num_partitions: 1,
                    replication_factor: 3
                  })
        end
        KafkaRailsIntegration.configure_with(path)
      end

      context 'with content' do
        let(:path) { './spec/files/kafka.yml' }

        it 'configure with key value pair ops' do
          expect(KafkaRailsIntegration.topics).to eq(topics)
          expect(KafkaRailsIntegration.config).to eq(expected_config.except(:client_id))
        end
      end

      context 'without content' do
        let(:topics) { [] }
        let(:path) { './spec/files/empty_kafka_config.yml' }

        it 'configure with key value pair ops' do
          expect(KafkaRailsIntegration.topics).to be_empty
          expect(KafkaRailsIntegration.config).to eq(default_config)
        end
      end

      context 'with wrong path' do
        let(:topics) { [] }
        let(:path) { './not_exists.yml' }

        it 'log an error' do
          expect(logger).to have_received(:warn).with("YAML configuration file couldn't be found.").once
          expect(KafkaRailsIntegration.topics).to be_empty
          expect(KafkaRailsIntegration.config).to eq(default_config)
        end
        end

      context 'with error file' do
        let(:topics) { [] }
        let(:path) { './spec/files/error_kafka_config.yml' }

        it 'log an error' do
          expect(logger).to have_received(:warn).with("YAML configuration file contains invalid syntax.").once
          expect(KafkaRailsIntegration.topics).to be_empty
          expect(KafkaRailsIntegration.config).to eq(default_config)
        end
      end
    end
  end
end
