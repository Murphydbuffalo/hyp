module Hyp
  module ExperimentUserTrialHelpers
    module Callbacks
      def self.extended(extending_class)
        extending_class.instance_eval(
          <<-RUBY
            after_create do
              return unless Hyp.experiment_complete_callback.respond_to?(:call) && experiment.finished?
              Hyp.experiment_complete_callback.call(experiment_id)
            end
          RUBY
        )
      end
    end
  end
end