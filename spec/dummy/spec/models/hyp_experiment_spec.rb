# frozen_string_literal: true

require 'rails_helper'
require '../../lib/hyp/experiment_repo'

describe Hyp::Experiment do
  subject do
    Hyp::ExperimentRepo.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "Baby's first experiment"
    )
  end

  let(:idiot1) do
    Idiot.create!(name: 'Dan', age: 29)
  end

  let(:idiot2) do
    Idiot.create!(name: 'Ben', age: 29)
  end

  describe '#sample_size' do
    it 'returns a reasonable number' do
      expect(subject.sample_size).to be 474
    end
  end

  describe '#started?' do
    context 'no trials have been recorded' do
      it 'returns false' do
        expect(subject.started?).to be false
      end
    end

    context 'a trial has been recorded' do
      before do
        subject.record_trial(idiot1)
      end

      it 'returns true' do
        expect(subject.started?).to be true
      end
    end
  end

  describe '#finished?' do
    before do
      allow(subject).to receive(:sample_size) { 1 }
    end

    context 'no trials have been recorded' do
      it 'returns false' do
        expect(subject.finished?).to be false
      end
    end

    context 'all trials have been recorded for one variant' do
      before do
        subject.record_trial(idiot1)
      end

      it 'returns false' do
        expect(subject.finished?).to be false
      end
    end

    context 'all trials have been recorded for all variants' do
      before do
        allow(subject).to receive(:variant_for).with(idiot1) { subject.control_variant }
        allow(subject).to receive(:variant_for).with(idiot2) { subject.treatment_variant }
        subject.record_trial(idiot1)
        subject.record_trial(idiot2)
      end

      it 'returns true' do
        expect(subject.finished?).to be true
      end
    end
  end

  describe '#winner' do
    context 'experiment is still running' do
      before do
        allow(subject).to receive(:finished?) { false }
      end

      it 'returns nil' do
        expect(subject.winner).to be nil
      end
    end

    context 'no significant result was found' do
      before do
        allow(subject).to receive(:finished?) { true }
        allow(subject).to receive(:significant_result?) { false }
      end

      it 'returns nil' do
        expect(subject.winner).to be nil
      end
    end

    context 'the effect size is smaller than the MDE' do
      before do
        allow(subject).to receive(:finished?) { true }
        allow(subject).to receive(:significant_result?) { true }
        allow(subject).to receive(:effect_size) { 0.04 }
      end

      it 'returns nil' do
        expect(subject.winner).to be nil
      end
    end

    context 'one variant is significantly better than the other' do
      before do
        allow(subject).to receive(:finished?) { true }
        allow(subject).to receive(:significant_result?) { true }

        allow(subject).to receive(:variant_for).with(idiot1) { subject.control_variant }
        allow(subject).to receive(:variant_for).with(idiot2) { subject.treatment_variant }

        subject.record_conversion(idiot1) # 100% conversion rate
        subject.record_trial(idiot2) # 0% conversion rate
      end

      it 'returns the winning variant' do
        expect(subject.winner).to eq subject.control_variant
      end
    end
  end

  describe '#loser' do
    context 'experiment is still running' do
      before do
        allow(subject).to receive(:finished?) { false }
      end

      it 'returns nil' do
        expect(subject.loser).to be nil
      end
    end

    context 'no significant result was found' do
      before do
        allow(subject).to receive(:finished?) { true }
        allow(subject).to receive(:significant_result?) { false }
      end

      it 'returns nil' do
        expect(subject.loser).to be nil
      end
    end

    context 'one variant is significantly better than the other' do
      before do
        allow(subject).to receive(:finished?) { true }
        allow(subject).to receive(:significant_result?) { true }

        allow(subject).to receive(:variant_for).with(idiot1) { subject.control_variant }
        allow(subject).to receive(:variant_for).with(idiot2) { subject.treatment_variant }

        subject.record_conversion(idiot1) # 100% conversion rate
        subject.record_trial(idiot2) # 0% conversion rate
      end

      it 'returns the losing variant' do
        expect(subject.loser).to eq subject.treatment_variant
      end
    end
  end

  describe '#progress' do
    context 'no trials' do
      it 'returns 0.0' do
        expect(subject.progress).to be 0.0
      end
    end

    context 'some trials' do
      before do
        10.times do |i|
          subject.record_trial(
            Idiot.new(name: "Idiot #{i}", age: i)
          )
        end
      end

      it 'returns the percentage of the required number of trials that have been required' do
        expect(subject.progress).to be 0.0105
      end
    end
  end

  describe '#control_conversion_rate' do
    before do
      allow(subject).to receive(:variant_for) { subject.control_variant }

      10.times do |i|
        subject.record_trial(
          Idiot.create!(name: "Idiot #{i}", age: i)
        )
      end
    end

    context 'no conversions' do
      it 'returns 0.0' do
        expect(subject.control_conversion_rate).to be 0.0
      end
    end

    context 'some trials converted' do
      before do
        Idiot.limit(5).each do |idiot|
          subject.record_conversion(idiot)
        end
      end

      it 'returns the percentage of the required number of trials that have been required' do
        expect(subject.control_conversion_rate).to be 0.5
      end
    end
  end

  describe '#treatment_conversion_rate' do
    before do
      allow(subject).to receive(:variant_for) { subject.treatment_variant }

      10.times do |i|
        subject.record_trial(
          Idiot.create!(name: "Idiot #{i}", age: i)
        )
      end
    end

    context 'no conversions' do
      it 'returns 0.0' do
        expect(subject.treatment_conversion_rate).to be 0.0
      end
    end

    context 'some trials converted' do
      before do
        Idiot.limit(7).each do |idiot|
          subject.record_conversion(idiot)
        end
      end

      it 'returns the percentage of the required number of trials that have been required' do
        expect(subject.treatment_conversion_rate).to be 0.7
      end
    end
  end
end
