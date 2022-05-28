# frozen_string_literal: true

require 'json'

module KafkaRailsIntegration
  class Producer
    MODES = %i[sync async buffer].freeze
    # Send payload to Kafka
    #
    # @param payload [Object] Hash will dump to string. any other `#to_s`
    # @param topic [String] kafka topic name.
    # @param [Symbol] mode [:buffer (default), :async, :sync]
    #
    # rubocop:disable Metrics/MethodLength
    def self.produce(payload, topic = 'default', mode = :buffer)
      payload = payload.is_a?(Hash) ? JSON.dump(payload) : payload.to_s

      case mode
      when :buffer
        # kafka_client.buffer(topic: topic.underscore, payload:)
        @dirty = true
        kafka_client.produce(topic: topic, payload:)
      when :async
        # kafka_client.produce_async(topic: topic, payload:)
      when :sync
        kafka_client.produce(topic: topic, payload:)
      else
        raise "Invalid mode. Must be one of #{MODES}"
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Flush messages to Kafka
    def self.deliver!
      return unless @dirty

      @dirty = false
      kafka_client.deliver_messages
    end
  end
end
