# frozen_string_literal: true

require 'hyp/statistics/sample_size'
require 'hyp/statistics/hypothesis_test'
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
        if @started.nil?
          ExperimentUserTrial.where(experiment: self).exists?
        else
          @started
        end
      end

      def finished?
        if @finished.nil?
          variants.all? do |variant|
            num_trials(variant) >= sample_size
          end
        else
          @finished
        end
      end

      def winner
        return nil unless finished? && significant_result_found?

        if control_conversion_rate >= treatment_conversion_rate
          control_variant
        else
          treatment_variant
        end
      end

      def loser
        return nil unless finished? && significant_result_found?

        if control_conversion_rate < treatment_conversion_rate
          control_variant
        else
          treatment_variant
        end
      end

      def approximate_percent_finished
        @approximate_percent_finished ||= num_trials(variants.first) / sample_size
      end

      def control_conversion_rate
        @control_conversion_rate ||= begin
          control_number_of_trials = num_trials(control_variant)

          if control_number_of_trials.zero?
            0.0
          else
            control_trials.where(converted: true).count / control_number_of_trials.to_f
          end
        end
      end

      def treatment_conversion_rate
        @treatment_conversion_rate ||= begin
          treatment_number_of_trials = num_trials(treatment_variant)

          if treatment_number_of_trials.zero?
            0.0
          else
            treatment_trials.where(converted: true).count / treatment_number_of_trials.to_f
          end
        end
      end

      def effect_size
        hypothesis_test.effect_size.abs
      end

      def significant_result_found?
        hypothesis_test.result == :reject_null
      end

      def variant_name(user)
        variant_for(user).name
      end

      def record_trial(user)
        variant = variant_for(user)
        find_or_create_trial(variant, user) if num_trials(variant) < sample_size
      end

      def record_conversion(user)
        record_trial(user)&.update!(converted: true)
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

        def variant_for(user)
          user_assigner = UserAssignment.new(user: user, experiment: self)
          variants.order(:id)[user_assigner.variant_index]
        end

        def num_trials(variant)
          ExperimentUserTrial.where(variant: variant).count
        end

        def trial_for(user)
          ExperimentUserTrial.where(experiment: self, user: user).first
        end

        def find_or_create_trial(variant, user)
          ExperimentUserTrial.find_or_initialize_by(
            experiment:  self,
            variant: variant,
            user:        user
          ).save!
        end

        def control_trials
          ExperimentUserTrial.where(
            experiment: self,
            variant: control_variant
          )
        end

        def treatment_trials
          ExperimentUserTrial.where(
            experiment: self,
            variant: treatment_variant
          )
        end

        def control_variant
          variants.control.first
        end

        def treatment_variant
          variants.treatment.first
        end
    end
  end
end
