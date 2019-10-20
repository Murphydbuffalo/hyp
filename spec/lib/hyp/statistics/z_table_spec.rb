# frozen_string_literal: true

require 'hyp/statistics/z_table'

describe Hyp::Statistics::ZTable do
  # Takes in a `test_statistic` argument, which is some number of standard
  # deviations from the mean of a normal distribution.
  describe '.two_tail_probability' do
    it 'returns the probability of a value at least as far form the mean as the passed in test statistic occurring' do
      expect(described_class.two_tail_probability(0.5).round(3)).to be 0.617
      expect(described_class.two_tail_probability(1.0).round(3)).to be 0.317
      expect(described_class.two_tail_probability(1.5).round(3)).to be 0.134
      expect(described_class.two_tail_probability(2.0).round(3)).to be 0.046
      expect(described_class.two_tail_probability(2.5).round(3)).to be 0.012
      expect(described_class.two_tail_probability(3.0).round(3)).to be 0.003
      expect(described_class.two_tail_probability(3.49).round(3)).to be 0.0
    end

    it 'uses the absolute value of the test statistic' do
      expect(described_class.two_tail_probability(-2.0).round(3)).to be 0.046
    end

    it 'rounds the test statistic to the nearest hundreth' do
      expect(described_class.two_tail_probability(2.0001).round(3)).to be 0.046
    end

    it 'caps the test statistic at 3.49' do
      expect(described_class.two_tail_probability(7).round(3)).to be 0.0
    end
  end
end
