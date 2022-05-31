# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example) do
    client = double('Client')
    producer = double('Producer')
    allow(client).to receive(:producer).and_return(producer)
    allow(client).to receive(:create_topic)
    allow(Kafka).to receive(:new).and_return(client)

    allow(producer).to receive(:produce)
  end
end
