# frozen_string_literal: true

require 'hyp/statistics/sample_size'

describe Hyp::Statistics::SampleSize do
  describe '#to_i' do
    context 'alpha = 0.05 and power = 0.80' do
      let(:alpha) { 0.05 }
      let(:power) { 0.80 }

      # Larger effects are easier to detect as significant results
      it 'decreases as MDE increases' do
        control = 0.05

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.01
        ).to_i

        expect(sample_size_a).to be 8_359

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.02
        ).to_i

        expect(sample_size_b).to be 2_312

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.05
        ).to_i

        expect(sample_size_c).to be 474
      end

      # Control proportions closer to 0.5 have higher standard deviations (see
      # `BernoulliDistributionStatistics` for details), which require larger
      # sample sizes to account for.
      it 'increases as the control proportion increases' do
        mde = 0.02

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.01,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_a).to be 868

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.02,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_b).to be 1_241

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.05,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_c).to be 2_312
      end
    end

    # Larger sample sizes are required for lower levels of alpha (reduced chance
    # of false positives).
    context 'alpha = 0.01 and power = 0.80' do
      let(:alpha) { 0.01 }
      let(:power) { 0.80 }

      # Larger effects are easier to detect as significant results
      it 'decreases as MDE increases' do
        control = 0.05

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.01
        ).to_i

        expect(sample_size_a).to be 12_338

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.02
        ).to_i

        expect(sample_size_b).to be 3_390

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.05
        ).to_i

        expect(sample_size_c).to be 685
      end

      # Control proportions closer to 0.5 have higher standard deviations (see
      # `BernoulliDistributionStatistics` for details), which require larger
      # sample sizes to account for.
      it 'increases as the control proportion increases' do
        mde = 0.02

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.01,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_a).to be 1_241

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.02,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_b).to be 1_796

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.05,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_c).to be 3_390
      end
    end

    # Larger sample sizes are required for higher power (reduced chance of false negatives)
    context 'alpha = 0.05 and power = 0.90' do
      let(:alpha) { 0.05 }
      let(:power) { 0.90 }

      # Larger effects are easier to detect as significant results
      it 'decreases as MDE increases' do
        control = 0.05

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.01
        ).to_i

        expect(sample_size_a).to be 11_122

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.02
        ).to_i

        expect(sample_size_b).to be 3_061

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.05
        ).to_i

        expect(sample_size_c).to be 621
      end

      # Control proportions closer to 0.5 have higher standard deviations (see
      # `BernoulliDistributionStatistics` for details), which require larger
      # sample sizes to account for.
      it 'increases as the control proportion increases' do
        mde = 0.02

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.01,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_a).to be 1_127

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.02,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_b).to be 1_626

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.05,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_c).to be 3_061
      end
    end

    context 'alpha = 0.01 and power = 0.90' do
      let(:alpha) { 0.01 }
      let(:power) { 0.90 }

      # Larger effects are easier to detect as significant results
      it 'decreases as MDE increases' do
        control = 0.05

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.01
        ).to_i

        expect(sample_size_a).to be 15_663

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.02
        ).to_i

        expect(sample_size_b).to be 4_291

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: control,
          minimum_detectable_effect: 0.05
        ).to_i

        expect(sample_size_c).to be 861
      end

      # Control proportions closer to 0.5 have higher standard deviations (see
      # `BernoulliDistributionStatistics` for details), which require larger
      # sample sizes to account for.
      it 'increases as the control proportion increases' do
        mde = 0.02

        sample_size_a = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.01,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_a).to be 1_553

        sample_size_b = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.02,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_b).to be 2_260

        sample_size_c = described_class.new(
          alpha: alpha,
          power: power,
          control: 0.05,
          minimum_detectable_effect: mde
        ).to_i

        expect(sample_size_c).to be 4_291
      end
    end
  end
end
