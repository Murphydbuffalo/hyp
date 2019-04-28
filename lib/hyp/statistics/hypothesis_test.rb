require 'hyp/statistics/z_table'
require 'hyp/statistics/bernoulli_distribution_statistics'

module Hyp
  module Statistics
    # Two-tail test for the difference in proportions from two samples
    # h0: (control - treatment)  = 0
    # hA: (control - treatment) != 0
    class HypothesisTest
      include BernoulliDistributionStatistics

      def initialize(control:, treatment:, sample_size:, alpha:)
        @control     = control
        @treatment   = treatment
        @sample_size = sample_size
        @alpha       = alpha
      end

      def result
        if p_value < alpha
          :reject_null
        else
          :fail_to_reject_null
        end
      end

      private

      attr_reader :control, :treatment, :sample_size, :alpha

      def p_value
        @p_value ||= ZTable.two_tail_probability(test_statistic)
      end

      def test_statistic
        @test_statistic ||= effect_size / standard_deviation
      end

      def effect_size
        @effect_size ||= treatment - control
      end

      def standard_deviation
        @standard_deviation ||= Math.sqrt(
          bernoulli_distribution_standard_deviation(control)   / sample_size +
          bernoulli_distribution_standard_deviation(treatment) / sample_size
        )
      end
    end
  end
end
