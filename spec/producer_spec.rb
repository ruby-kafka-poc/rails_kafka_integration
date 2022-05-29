# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KafkaRailsIntegration::Producer do
  let(:producer) { double(:Producer) }
  let(:client) { KafkaRailsIntegration::Producer }

  before do
    allow(KafkaRailsIntegration).to receive(:producer).and_return(producer)
    allow(producer).to receive(:produce)
    allow(producer).to receive(:deliver_messages)
  end

  context '#produce' do
    context 'with hash' do
      let(:payload) do
        {
          bar: 'foo',
          baz: 5
        }
      end

      context 'with buffer mode' do
        it 'use the default topic and mode' do
          expect(client.produce(payload)).to be_truthy
          expect(producer).to have_received(:produce).with(JSON.dump(payload), topic: 'default')
        end

        it 'use the default mode' do
          expect(client.produce(payload, 'cool_topic')).to be_truthy
          expect(producer).to have_received(:produce).with(JSON.dump(payload), topic: 'cool_topic')
          expect(producer).not_to have_received(:deliver_messages)
        end

        it 'stringify the payload' do
          expect(client.produce(:some_symbol_message, 'cool_topic')).to be_truthy
          expect(producer).to have_received(:produce).with('some_symbol_message', topic: 'cool_topic')
          expect(producer).not_to have_received(:deliver_messages)
        end
      end

      context 'with async mode' do
        it 'use the async mode' do
          expect { client.produce(payload, 'cool_topic', :async) }.to raise_exception(NotImplementedError)
        end
      end

      context 'with sync mode' do
        it 'use the sync mode' do
          expect(client.produce(payload, 'cool_topic', :sync)).to be_truthy
          expect(producer).to have_received(:produce).with(JSON.dump(payload), topic: 'cool_topic')
          expect(producer).to have_received(:deliver_messages)
        end
      end

      context 'with wrong mode' do
        it 'fail' do
          expect { client.produce(payload, 'cool_topic', :something) }.to raise_exception
          expect(producer).not_to have_received(:produce)
          expect(producer).not_to have_received(:deliver_messages)
        end
      end
    end
  end

  context '#deliver!' do
    context 'dirty' do
      before { client.instance_variable_set('@dirty', true) }

      it 'deliver the messages' do
        expect(client.deliver!).to be_truthy
        expect(client.instance_variable_get('@dirty')).to be_falsey
        expect(producer).to have_received(:deliver_messages).once
      end
    end

    context 'clean' do
      it 'deliver the messages' do
        expect(client.deliver!).to be_falsey
        expect(client.instance_variable_get('@dirty')).to be_falsey
        expect(producer).not_to have_received(:deliver_messages)
      end
    end
  end
end
