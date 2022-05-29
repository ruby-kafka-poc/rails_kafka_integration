# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example) do
    allow_any_instance_of(Kafka).to receive(:produce)
    allow_any_instance_of(Kafka).to receive(:deliver_messages)
    allow_any_instance_of(Kafka).to receive(:create_topic)
  end
end
