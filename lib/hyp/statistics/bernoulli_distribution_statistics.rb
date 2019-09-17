module Hyp
  module Statistics
    module BernoulliDistributionStatistics
      # https://en.wikipedia.org/wiki/Bernoulli_distribution
      def bernoulli_distribution_variance(prob_success)
        prob_success * (1.0 - prob_success)
      end
    end
  end
end
