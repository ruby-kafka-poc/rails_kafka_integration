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
        @dirty = true
        KafkaRailsIntegration.producer.produce(payload, topic:)
      when :async
        raise NotImplementedError
      when :sync
        KafkaRailsIntegration.producer.produce(payload, topic:)
        KafkaRailsIntegration.producer.deliver_messages
      else
        raise "Invalid mode. Must be one of #{MODES}"
      end

      @dirty
    end
    # rubocop:enable Metrics/MethodLength

    # Flush messages to Kafka
    def self.deliver!
      return false unless @dirty

      @dirty = false
      KafkaRailsIntegration.producer.deliver_messages

      true
    end
  end
end
