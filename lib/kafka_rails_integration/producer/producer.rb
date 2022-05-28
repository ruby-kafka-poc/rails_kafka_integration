# frozen_string_literal: true

require 'json'

module KafkaRailsIntegration
  class Producer
    MODES = %i[sync async buffer].freeze
    # Send payload to Kafka
    #
    # @param payload [Object] Hash will dump to string. any other `#to_s`
    #
    # @param topic [String] kafka topic name.
    # rubocop:disable Metrics/MethodLength
    def self.produce(payload, topic = 'default', mode = :buffer)
      payload = payload.is_a?(Hash) ? JSON.dump(payload) : payload.to_s

      case mode
      when :buffer
        client.buffer(topic: topic.underscore, payload:)
        @dirty = true
      when :async
        client.produce_async(topic: topic.underscore, payload:)
      when :sync
        client.produce_sync(topic: topic.underscore, payload:)
      else
        raise "Invalid mode. Must be one of #{MODES}"
      end
    end

    # rubocop:enable Metrics/MethodLength

    # Flush messages to Kafka
    def self.deliver!
      return unless @dirty

      @dirty = false
      client.flush_sync
    end

    def self.client
      @client ||= WaterDrop::Producer.new.tap do |producer|
        producer.setup do |config|
          config.deliver = true
          config.kafka = {
            'bootstrap.servers': KafkaRailsIntegration.config[:bootstrap_servers],
            'security.protocol': KafkaRailsIntegration.config[:security_protocol],
            'sasl.mechanisms': KafkaRailsIntegration.config[:sasl_mechanism],
            'sasl.username': KafkaRailsIntegration.config[:sasl_username],
            'sasl.password': KafkaRailsIntegration.config[:sasl_password],
          }
        end
      end
    end
  end
end
