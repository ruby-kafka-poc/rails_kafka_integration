# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example) do
    # allow_any_instance_of(Rdkafka::Producer).to receive(:produce)
    # allow_any_instance_of(WaterDrop::Producer).to receive(:flush_sync)
    allow_any_instance_of(Kafka).to receive(:produce)
    allow_any_instance_of(Kafka).to receive(:deliver_messages)
  end
end
