# frozen_string_literal: true

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

      def effect_size
        @effect_size ||= (treatment - control).abs
      end

      def significant_result?
        result == :reject_null
      end

      private

        attr_reader :control, :treatment, :sample_size, :alpha

        # The probability of seeing a test statistic at least as far from the mean
        # on a normal distributio as our is.
        def p_value
          @p_value ||= ZTable.two_tail_probability(test_statistic)
        end

        # The effect size measured in number of standard deviations.
        def test_statistic
          return 0.0 if standard_deviation.zero?
          effect_size / standard_deviation
        end

        # The variance of the difference between two random variables is the sum
        # of each of those random variables' variations. You can think of this as
        # each variable contributing some amount of uncertainty to the difference.
        # https://www.khanacademy.org/math/ap-statistics/random-variables-ap/combining-random-variables/v/variance-of-sum-and-difference-of-random-variables
        def standard_deviation
          @standard_deviation ||= Math.sqrt(
            bernoulli_distribution_variance(control)   / sample_size +
            bernoulli_distribution_variance(treatment) / sample_size
          )
        end
    end
  end
end
