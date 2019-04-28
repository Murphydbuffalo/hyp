module Hyp
  module ApplicationHelper
    def record_trial(experiment:, user_identifier:)
      experiment = Experiment.find_by(name: experiment)
      experiment.record_trial(user_identifier)
    end

    def record_conversion(experiment:, user_identifier:)
      experiment = Experiment.find_by(name: experiment)
      experiment.record_conversion(user_identifier)
    end

    def record_trial_and_conversion(experiment:, user_identifier:)
      experiment = Experiment.find_by(name: experiment)
      experiment.record_trial_and_conversion(user_identifier)
    end
  end
end
