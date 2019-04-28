require 'hyp/user_assignment'

module Hyp
  class Experiment < ApplicationRecord
    has_many  :alternatives, foreign_key: 'hyp_experiment_id', dependent: :destroy

    validates :alpha, inclusion: { in: [0.05, 0.01] }
    validates :power, inclusion: { in: [0.80, 0.90] }
    validates :control, numericality:
      { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates :minimum_detectable_effect, numericality:
      { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates_uniqueness_of :name

    def record_trial(user_identifier)
      alternative = alternative_for(user_identifier)
      alternative.increment!(:trials) if alternative.trials < sample_size
    end

    def record_conversion(user_identifier)
      alternative = alternative_for(user_identifier)
      alternative.increment!(:conversions) if alternative.trials < sample_size
    end

    def record_trial_and_conversion(user_identifier)
      alternative = alternative_for(user_identifier)

      return unless alternative.trials < sample_size

      alternative.increment!(:trials)
      alternative.increment!(:conversions)
    end

    private

    def alternative_for(user_identifier)
      assigner = UserAssignment.new(identifier: user_identifier, alternatives: alternatives)
      alternatives.order(:id)[assigner.index]
    end
  end
end
