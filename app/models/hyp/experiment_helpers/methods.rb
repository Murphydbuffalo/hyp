require 'hyp/statistics/sample_size'
require 'hyp/user_assignment'

module Hyp
  module ExperimentHelpers
    module Methods
      def sample_size
        @sample_size ||= Statistics::SampleSize.new(
          alpha:                     alpha,
          power:                     power,
          control:                   control,
          minimum_detectable_effect: minimum_detectable_effect
        ).to_i
      end

      def started?
        ExperimentUserTrial.where(experiment: self).exists?
      end

      def finished?
        alternatives.all? do |alternative|
          num_trials(alternative) >= sample_size
        end
      end

      def approximate_percent_finshed
        num_trials(alternatives.first) / sample_size
      end

      def control_conversion_rate
        control_number_of_trials = num_trials(control_alternative)

        if control_number_of_trials.zero?
          0.0
        else
          control_trials.where(converted: true).count / control_number_of_trials.to_f
        end
      end

      def treatment_conversion_rate
        treatment_number_of_trials = num_trials(treatment_alternative)

        if treatment_number_of_trials.zero?
          0.0
        else
          treatment_trials.where(converted: true).count / treatment_number_of_trials.to_f
        end
      end

      def effect_size
        hypothesis_test.effect_size.abs
      end

      def significant_result_found?
        hypothesis_test.result == :reject_null
      end

      def alternative_name(user)
        alternative_for(user).name
      end

      def record_trial(user)
        alternative = alternative_for(user)
        find_or_create_trial(alternative, user) if num_trials(alternative) < sample_size
      end

      def record_conversion(user)
        trial_for(user)&.update!(converted: true)
      end

      def record_trial_and_conversion(user)
        record_trial(user)
        record_conversion(user)
      end

      private

        def hypothesis_test
          @hypothesis_test ||= Hyp::Statistics::HypothesisTest.new(
            control:     control_conversion_rate,
            treatment:   treatment_conversion_rate,
            sample_size: sample_size,
            alpha:       alpha
          )
        end

        def alternative_for(user)
          user_assigner = UserAssignment.new(user: user, experiment: self)
          alternatives.order(:id)[user_assigner.alternative_index]
        end

        def num_trials(alternative)
          ExperimentUserTrial.where(alternative: alternative).count
        end

        def trial_for(user)
          ExperimentUserTrial.where(experiment: self, user: user).first
        end

        def find_or_create_trial(alternative, user)
          ExperimentUserTrial.find_or_initialize_by(
            experiment:  self,
            alternative: alternative,
            user:        user
          ).save!
        end

        def control_trials
          ExperimentUserTrial.where(
            experiment: self,
            alternative: control_alternative
          )
        end

        def treatment_trials
          ExperimentUserTrial.where(
            experiment: self,
            alternative: treatment_alternative
          )
        end

        def control_alternative
          alternatives.where(name: 'control').first
        end

        def treatment_alternative
          alternatives.where(name: 'treatment').first
        end
    end
  end
end
