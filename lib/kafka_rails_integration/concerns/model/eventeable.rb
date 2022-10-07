# frozen_string_literal: true

require 'active_support'

module KafkaRailsIntegration
  module Concerns
    module Model
      module Eventeable
        extend ActiveSupport::Concern

        attr_reader :options

        # Set as_json object to serialize payload
        # @param [Hash] options as_json serializable options
        def eventeable(options = {})
          @options = options
        end

        included do
          after_commit :publish_created!, on: :create
          after_commit :publish_edited!, on: :update
          after_commit :publish_deleted!, on: :destroy
        end

        private

        def publish!(action)
          topic = "#{self.class.name}s".underscore
          return unless KafkaRailsIntegration.topics.include?(topic)

          KafkaRailsIntegration::Producer.produce(
            payload(action),
            topic
          )
        end

        def publish_created!
          publish!(:created)
        end

        def publish_edited!
          publish!(:edited)
        end

        def publish_deleted!
          publish!(:deleted)
        end

        def payload(action)
          as_json(options).merge(
            entity: self.class.name,
            action:
          )
        end
      end
    end
  end
end
