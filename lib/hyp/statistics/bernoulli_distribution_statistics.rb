module Hyp
  module Statistics
    module BernoulliDistributionStatistics
      def bernoulli_distribution_standard_deviation(prob_success)
        prob_success * (1.0 - prob_success)
      end
    end
  end
end
