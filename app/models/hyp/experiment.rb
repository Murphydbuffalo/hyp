require 'hyp/user_assignment'
require 'hyp/statistics/sample_size'

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

    def sample_size
      @sample_size ||= Statistics::SampleSize.new(
        alpha:                     alpha,
        power:                     power,
        control:                   control,
        minimum_detectable_effect: minimum_detectable_effect
      ).to_i
    end

    def finished?
      alternatives.all? do |alternative|
        num_trials(alternative) >= sample_size
      end
    end

    def record_trial(user)
      alternative = alternative_for(user)
      find_or_create_trial(alternative, user) if num_trials(alternative) < sample_size
    end

    def record_conversion(user)
      trial = trial_for(user)
      trial.update!(converted: true) if num_trials(trial.alternative) < sample_size
    end

    def record_trial_and_conversion(user)
      record_trial(user)
      record_conversion(user)
    end

    private

    def alternative_for(user)
      assigner = UserAssignment.new(user: user, alternatives: alternatives)
      alternatives.order(:id)[assigner.index]
    end

    def trial_for(user)
      ExperimentUserTrial.find_by(experiment: self, user: user)
    end

    def num_trials(alternative)
      ExperimentUserTrial.where(alternative: alternative).count
    end

    def find_or_create_trial(alternative, user)
      ExperimentUserTrial.find_or_initialize_by(
        experiment:  self,
        alternative: alternative,
        user:        user
      ).save!
    end
  end
end
