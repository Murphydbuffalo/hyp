module Hyp
  class ExperimentRepo
    class << self
      def list(offset: 0, limit: 25)
        Hyp::Experiment.offset(offset).limit(limit).includes(:alternatives)
      end

      def find(id)
        Hyp::Experiment.includes(:alternatives).find(id)
      end

      def find_by(query)
        Hyp::Experiment.includes(:alternatives).where(query).first
      end

      def create(params)
        send("#{Hyp.db_interface}_create", params)
      end

      private

      def active_record_create(params)
        experiment = Hyp::Experiment.new(params)

        ActiveRecord::Base.transaction do
          if experiment.save
            experiment.alternatives.create(alternatives_params)
          end
        end

        experiment
      end

      def mongoid_create(params)
        experiment = Hyp::Experiment.new(params)

        if experiment.save
          experiment.alternatives.create(alternatives_params)
        end

        experiment
      end

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
