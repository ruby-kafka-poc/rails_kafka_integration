# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KafkaRailsIntegration do
  it 'has a version number' do
    expect(KafkaRailsIntegration::VERSION).not_to be_nil
  end

  context '#configure' do
    let(:expected_config) do
      {
        bootstrap_servers: 'localhost:9092',
        request_required_acks: 5,
        security_protocol: nil,
        sasl_mechanism: nil,
        sasl_username: nil,
        sasl_password: nil
      }
    end

    context 'without topics' do
      before { KafkaRailsIntegration.configure(request_required_acks: 5) }

      it 'configure with key value pair ops' do
        expect(KafkaRailsIntegration.config).to eq(expected_config)
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
  end
end
