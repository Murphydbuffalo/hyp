module Hyp
  class ExperimentRepo
    class << self
      def find_by(query)
        send("#{Hyp.db_interface}_find_by", query)
      end

      def create(params)
        send("#{Hyp.db_interface}_create", params)
      end

      private

      def active_record_find_by(query)
        Hyp::Experiment.find_by(query)
      end

      def mongoid_find_by(query)
        Hyp::Experiment.where(query).first
      end

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
