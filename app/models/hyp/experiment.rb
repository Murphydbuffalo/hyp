require 'hyp/user_assignment'

module Hyp
  class Experiment < ApplicationRecord
    has_many  :alternatives, foreign_key: 'hyp_experiment_id', dependent: :destroy
    has_many  :experiment_user_trials, foreign_key: 'hyp_experiment_id', dependent: :destroy

    validates :alpha, inclusion: { in: [0.05, 0.01] }
    validates :power, inclusion: { in: [0.80, 0.90] }
    validates :control, numericality:
      { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates :minimum_detectable_effect, numericality:
      { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates_uniqueness_of :name

    def finished?
      alternatives.all? do |alternative|
        num_trials(alternative) >= sample_size
      end
    end

    def record_trial(user_identifier)
      alternative = alternative_for(user_identifier)
      find_or_create_trial(alternative) if num_trials(alternative) < sample_size
    end

    def record_conversion(user_identifier)
      trial = trial_for(user_identifer)
      trial.update!(converted: true) if num_trials(alternative) < sample_size
    end

    def record_trial_and_conversion(user_identifier)
      record_trial(user_identifer)
      record_conversion(user_identifer)
    end

    private

    def alternative_for(user_identifier)
      assigner = UserAssignment.new(identifier: user_identifier, alternatives: alternatives)
      alternatives.order(:id)[assigner.index]
    end

    def trial_for(user_identifer)
      ExperimentUserTrial.find_by(experiment: self, user_id: user_identifer)
    end

    def num_trials(alternative)
      ExperimentUserTrial.where(alternative: alternative).count
    end

    def find_or_create_trial(alternative, user_identifier)
      ExperimentUserTrial.find_or_initialize_by(
        experiment:  self,
        alternative: alternative,
        user_id:     user_identifier.to_i
      ).save!
    end
  end
end
