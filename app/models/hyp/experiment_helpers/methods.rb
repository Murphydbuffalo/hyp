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
        return nil unless finished? && significant_result?

        if control_conversion_rate > treatment_conversion_rate
          control_variant
        elsif control_conversion_rate < treatment_conversion_rate
          treatment_variant
        end
      end

      def loser
        winner && variants.detect { |v| v != winner }
      end

      def progress
        @progress ||= (
          variants.sum { |v| num_trials(v) } / (sample_size * variants.count.to_f)
        ).round(4)
      end

      def control_conversion_rate
        @control_conversion_rate ||= conversion_rate(control_variant)
      end

      def treatment_conversion_rate
        @treatment_conversion_rate ||= conversion_rate(treatment_variant)
      end

      def record_trial(user)
        variant = variant_for(user)
        find_or_create_trial(variant, user) if num_trials(variant) < sample_size
      end

      def record_conversion(user)
        record_trial(user)&.update!(converted: true)
      end

      def control_variant
        variants.control.first
      end

      def treatment_variant
        variants.treatment.first
      end

      def variant_for(user)
        user_assigner = UserAssignment.new(user: user, experiment: self)
        variants.order(:id)[user_assigner.variant_index]
      end

      def effect_size
        hypothesis_test.effect_size
      end

      def significant_result?
        hypothesis_test.significant_result?
      end

      def conversion_query_param(user)
        query_param(user, 'conversion')
      end

      def trial_query_param(user)
        query_param(user, 'trial')
      end

      private

        def query_param(user, event_type)
          QueryParam.new(
            experiment: self,
            user:       user,
            event_type: event_type
          ).to_s
        end

        def conversion_rate(variant)
          number_of_trials = num_trials(variant)

          if number_of_trials.zero?
            0.0
          else
            variant.experiment_user_trials.where(converted: true).count / variant.experiment_user_trials.count.to_f
          end
        end

        def hypothesis_test
          @hypothesis_test ||= Hyp::Statistics::HypothesisTest.new(
            control:     control_conversion_rate,
            treatment:   treatment_conversion_rate,
            sample_size: sample_size,
            alpha:       alpha
          )
        end

        def num_trials(variant)
          ExperimentUserTrial.where(variant: variant).count
        end

        def trial_for(user)
          ExperimentUserTrial.where(experiment: self, user: user).first
        end

        def find_or_create_trial(variant, user)
          ExperimentUserTrial.find_or_initialize_by(
            experiment: self,
            variant:    variant,
            user:       user
          ).tap(&:save!)
        end

        def control_trials
          ExperimentUserTrial.where(experiment: self, variant: control_variant)
        end

        def treatment_trials
          ExperimentUserTrial.where(experiment: self, variant: treatment_variant)
        end
    end
  end
end
