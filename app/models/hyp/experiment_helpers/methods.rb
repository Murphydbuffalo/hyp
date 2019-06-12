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
    end
  end
end
