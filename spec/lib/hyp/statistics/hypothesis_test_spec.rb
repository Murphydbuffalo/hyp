# frozen_string_literal: true

require 'hyp/statistics/hypothesis_test'

describe Hyp::Statistics::HypothesisTest do
  describe '#result' do
    it 'returns :reject_null for sufficiently large effect sizes' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.065,
        alpha: 0.05,
        sample_size: 3_000
      )
      expect(subject.result).to be :reject_null
    end

    it 'returns :fail_to_reject_null for insufficiently large effect sizes' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.06,
        alpha: 0.05,
        sample_size: 3_000
      )
      expect(subject.result).to be :fail_to_reject_null
    end

    it 'returns :reject_null for modest effect sizes if the sample size is very large' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.0575,
        alpha: 0.05,
        sample_size: 9_000
      )
      expect(subject.result).to be :reject_null
    end

    it 'returns :fail_to_reject_null for insufficiently large effect sizes even with a big sample size' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.051,
        alpha: 0.05,
        sample_size: 9_000
      )
      expect(subject.result).to be :fail_to_reject_null
    end

    it 'returns :reject_null for sufficiently large effect sizes given a small alpha' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.07,
        alpha: 0.01,
        sample_size: 3_000
      )
      expect(subject.result).to be :reject_null
    end

    it 'returns :fail_to_reject_null for insufficiently large effect sizes given a small alpha' do
      subject = described_class.new(
        control: 0.05,
        treatment: 0.065,
        alpha: 0.01,
        sample_size: 3_000
      )
      expect(subject.result).to be :fail_to_reject_null
    end

    it 'returns :reject_null when the control is statistically significantly higher than the treatment' do
      subject = described_class.new(
        control: 0.07,
        treatment: 0.05,
        alpha: 0.05,
        sample_size: 3_000
      )
      expect(subject.result).to be :reject_null
    end
  end
end
