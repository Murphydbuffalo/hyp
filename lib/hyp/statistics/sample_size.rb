# frozen_string_literal: true

require 'hyp/statistics/bernoulli_distribution_statistics'

module Hyp
  module Statistics
    class SampleSize
      include BernoulliDistributionStatistics

      def initialize(alpha: 0.05, power: 0.80, control:, minimum_detectable_effect:)
        @alpha                     = alpha
        @power                     = power
        @control                   = control
        @minimum_detectable_effect = minimum_detectable_effect
      end

      # From "Sample Size Determination" by Ralph B. Dell, Steve Holleran, and
      # Rajasekhar Ramakrishnan - ILAR Journal Volume 43, Number 4 2002
      def to_i
        @to_i ||= (
          (
            (
              adjustment_for_power_and_alpha *
              (control_standard_deviation + treatment_standard_deviation)
            ) / absolute_difference_in_proportions ** 2
          ) + (2 / absolute_difference_in_proportions) + 2
        ).ceil
      end

      private

      attr_reader :alpha, :power, :control, :minimum_detectable_effect

      def adjustment_for_power_and_alpha
        @adjustment_for_power_and_alpha ||=
          if alpha == 0.05 && power == 0.80
            7.85
          elsif alpha == 0.01 && power == 0.80
            11.68
          elsif alpha == 0.05 && power == 0.90
            10.51
          elsif alpha == 0.01 && power == 0.90
            14.88
          else
            raise ArgumentError, 'Invalid alpha or power. Allowed values of alpha are 0.05 or 0.01, and allowed values of power are 0.8 or 0.9'
          end
      end

      def control_standard_deviation
        @control_standard_deviation ||=
          bernoulli_distribution_standard_deviation(control)
      end

      def treatment_standard_deviation
        @treatment_standard_deviation ||=
          bernoulli_distribution_standard_deviation(minimum_detectable_treatment)
      end

      def absolute_difference_in_proportions
        @absolute_difference_in_proportions ||=
          (control - minimum_detectable_treatment).abs
      end

      def minimum_detectable_treatment
        @minimum_detectable_treatment ||=
          control + minimum_detectable_effect
      end
    end
  end
end
