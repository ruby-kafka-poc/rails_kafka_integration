# frozen_string_literal: true

require_relative 'kafka_rails_integration/middlewares/deliver_messages'
require_relative 'kafka_rails_integration/producer/producer'
require_relative 'kafka_rails_integration/version'

module KafkaRailsIntegration
  class Error < StandardError; end

  # TODO: Add config
end
