# frozen_string_literal: true

require 'spec_helper'

module Rack
  REQUEST_METHOD = :request_method
end

RSpec.describe KafkaRailsIntegration::Middlewares::DeliverMessages do
  let(:content) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
  let(:app) { ->(_) { content } }
  subject { KafkaRailsIntegration::Middlewares::DeliverMessages.new(app) }

  before do
    allow(KafkaRailsIntegration::Producer).to receive(:deliver!)
  end

  context '#call' do
    context 'POST' do
      let(:env) { { request_method: 'POST' } }

      it 'call to deliver_messages' do
        expect(subject.call(env)).to be_truthy
        expect(KafkaRailsIntegration::Producer).to have_received(:deliver!)
      end
    end

    context 'PUT' do
      let(:env) { { request_method: 'PUT' } }

      it 'call to deliver_messages' do
        expect(subject.call(env)).to be_truthy
        expect(KafkaRailsIntegration::Producer).to have_received(:deliver!)
      end
    end

    context 'PATCH' do
      let(:env) { { request_method: 'PATCH' } }

      it 'call to deliver_messages' do
        expect(subject.call(env)).to be_truthy
        expect(KafkaRailsIntegration::Producer).to have_received(:deliver!)
      end
    end
    context 'DESTROY' do
      let(:env) { { request_method: 'DESTROY' } }

      it 'call to deliver_messages' do
        expect(subject.call(env)).to be_truthy
        expect(KafkaRailsIntegration::Producer).to have_received(:deliver!)
      end
    end
    context 'GET' do
      let(:env) { { request_method: 'GET' } }

      it 'call to deliver_messages' do
        expect(subject.call(env)).to eq(content)
        expect(KafkaRailsIntegration::Producer).not_to have_received(:deliver!)
      end
    end
  end
end
