module Hyp
  module Services
    class ExperimentCreation
      def initialize(experiment_params)
        @experiment_params = experiment_params.to_h
      end

      def run
        experiment = Hyp::Experiment.new(experiment_params)

        ActiveRecord::Base.transaction do
          if experiment.save
            experiment.alternatives.create(alternatives_params)
          end
        end

        experiment
      end

      private

      attr_reader :experiment_params

      def alternatives_params
        [
          {
            name: 'Control'
          },
          {
            name: 'Treatment'
          }
        ]
      end
    end
  end
end
