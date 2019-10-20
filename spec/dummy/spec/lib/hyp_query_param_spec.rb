# frozen_string_literal: true

require 'rails_helper'
require '../../lib/hyp/query_param'

describe Hyp::QueryParam do
  let(:exp) do
    Hyp::ExperimentRepo.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "Baby's first experiment"
    )
  end

  let(:user) do
    Idiot.create!(name: 'Dan', age: 29)
  end

  let(:conversion_param) do
    described_class.new(experiment: exp, user: user, event_type: 'conversion')
  end

  let(:trial_param) do
    described_class.new(experiment: exp, user: user, event_type: 'trial')
  end

  describe '#to_s' do
    subject do
      described_class.new(experiment: exp, user: user, event_type: 'conversion')
    end

    it 'returns a base 64 encoded string containing the experiment ID, user ID, and event type' do
      expect(Base64.decode64(subject.to_s)).to eq "#{exp.id}:#{user.id}:conversion"
    end
  end

  describe '.record_event_for' do
    it 'parses a base64 encoded string and calls #record_event' do
      expect {
        described_class.record_event_for(conversion_param.to_s)
      }.to change {
        Hyp::ExperimentUserTrial.count
      }.by(1)

      trial = Hyp::ExperimentUserTrial.last

      expect(trial.converted).to be true
      expect(trial.user).to eq user
      expect(trial.experiment).to eq exp
    end

    it 'gracefully handles garbage input' do
      expect(described_class.record_event_for(123)).to be nil
      expect(described_class.record_event_for(nil)).to be nil
      expect(described_class.record_event_for('')).to be nil

      bad_param = described_class.new(
        experiment: exp,
        user: user,
        event_type: 'poop'
      ).to_s

      expect(described_class.record_event_for(bad_param)).to be nil
    end
  end

  describe '#record_event' do
    context 'trial events' do
      it 'records a trial for the given user and experiment' do
        expect {
          trial_param.record_event
        }.to change {
          Hyp::ExperimentUserTrial.count
        }.by(1)

        trial = Hyp::ExperimentUserTrial.last

        expect(trial.converted).to be false
        expect(trial.user).to eq user
        expect(trial.experiment).to eq exp
      end
    end

    context 'conversion events' do
      it 'records a trial and conversion for the given user and experiment' do
        expect {
          conversion_param.record_event
        }.to change {
          Hyp::ExperimentUserTrial.count
        }.by(1)

        trial = Hyp::ExperimentUserTrial.last

        expect(trial.converted).to be true
        expect(trial.user).to eq user
        expect(trial.experiment).to eq exp
      end
    end
  end
end
