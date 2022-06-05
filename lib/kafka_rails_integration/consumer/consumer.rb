
# frozen_string_literal: true

require 'json'

module KafkaRailsIntegration
  class Consumer
    class << self
      attr_reader :subscribed_group_id, :subscribed_topic
    end

    def self.group_id(group)
      @subscribed_group_id = group
    end

    def self.topic(name)
      @subscribed_topic = name
    end

    def initialize
      super
      raise 'Topic required (topic :subscribed_topic)' unless self.class.subscribed_topic

      consumer.subscribe(self.class.subscribed_topic.to_s, start_from_beginning: true)
      consumer.each_message do |message|
        consume(message)
      end
    end

    def consume(_message)
      raise NotImplementedError
    end

    private

    def consumer
      raise 'group_id required (group_id :subscribed_group_id)' unless self.class.subscribed_group_id

      @consumer ||= KafkaRailsIntegration.consumer(self.class.subscribed_group_id.to_s)
    end
  end
end
