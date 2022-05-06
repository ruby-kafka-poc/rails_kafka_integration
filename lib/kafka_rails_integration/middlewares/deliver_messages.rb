# frozen_string_literal: true

module KafkaRailsIntegration
  module Middlewares
    class DeliverMessages
      VERBS = %w[POST PATCH PUT DESTROY].freeze

      def initialize(app)
        @app = app
      end

      # Flush to Kafka all messages after request end
      def call(env)
        @app.call(env)
      ensure
        Producer.deliver! if VERBS.include?(env[Rack::REQUEST_METHOD])
      end
    end
  end
end
