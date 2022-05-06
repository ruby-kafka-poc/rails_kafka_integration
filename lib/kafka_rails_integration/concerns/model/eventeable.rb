# frozen_string_literal: true

module KafkaRailsIntegration
  module Concerns
    module Model
      module Eventeable
        extend ActiveSupport::Concern

        included do
          after_commit :publish_created!, on: :create
          after_commit :publish_edited!, on: :update
          after_commit :publish_deleted!, on: :destroy
        end

        private

        def publish!(action)
          Kafka::Producer.produce(payload(action), "#{self.class.name}-#{action}".underscore)
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
          {
            entity: self.class.name,
            object: as_json,
            action:
          }
        end
      end
    end
  end
end
