# frozen_string_literal: true

require 'rspec'
require 'hyp/statistics/bernoulli_distribution_statistics'

describe Hyp::Statistics::BernoulliDistributionStatistics do
  describe '#bernoulli_distribution_variance' do
    subject do
      class Foo
        include Hyp::Statistics::BernoulliDistributionStatistics
      end.new
    end

    it 'returns the standard deviation of a Bernoulli distribution for a given probability of success' do
      expect(subject.bernoulli_distribution_variance(0.01).round(4)).to eq 0.0099
      expect(subject.bernoulli_distribution_variance(0.1).round(4)).to eq 0.090
      expect(subject.bernoulli_distribution_variance(1).round(4)).to eq 0.0
    end
  end
end
