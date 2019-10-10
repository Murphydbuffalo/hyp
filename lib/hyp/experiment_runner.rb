# frozen_string_literal: true

require 'hyp/experiment_repo'

module Hyp
  class ExperimentRunner
    def self.run(experiment_name, user:, control:, treatment:, record_trial: false)
      new(
        experiment_name,
        user,
        control,
        treatment,
        record_trial
      ).run
    end

    def initialize(experiment_name, user, control, treatment, record_trial)
      @experiment_name = experiment_name
      @user            = user
      @control         = control
      @treatment       = treatment
      @record_trial    = user
    end

    def run
      # TODO make it possible to configure this to raise an error
      return if experiment.nil?

      experiment.record_trial(user) if record_trial?

      variant.treatment? ? treatment.call : control.call
    end

    private

      attr_reader :experiment_name, :user, :control, :treatment, :record_trial

      def experiment
        @experiment ||= ExperimentRepo.find_by(name: experiment_name)
      end

      def variant
        @variant ||= experiment.variant_for(user)
      end

      def record_trial?
        @record_trial
      end
  end
end
