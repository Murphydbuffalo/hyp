module Hyp
  if Hyp.db_interface == :active_record
    class Experiment < ApplicationRecord
      include Hyp::ExperimentHelpers::Methods
      extend  Hyp::ExperimentHelpers::Validations

      has_many  :variants, foreign_key: 'hyp_experiment_id', dependent: :destroy
      has_many  :experiment_user_trials, foreign_key: 'hyp_experiment_id', dependent: :destroy
    end
  elsif Hyp.db_interface == :mongoid
    class Experiment
      include Mongoid::Document
      include Mongoid::Timestamps
      include Hyp::ExperimentHelpers::Methods
      extend  Hyp::ExperimentHelpers::Validations

      has_many  :variants, class_name: 'Hyp::Variant', foreign_key: 'hyp_experiment_id', dependent: :destroy
      has_many  :experiment_user_trials, class_name: 'Hyp::ExperimentUserTrial', foreign_key: 'hyp_experiment_id', dependent: :destroy

      field :name,                      type: String
      field :alpha,                     type: Float, default: 0.05
      field :power,                     type: Float, default: 0.80
      field :control,                   type: Float
      field :minimum_detectable_effect, type: Float

      index({ name: 1 }, { unique: true })

      # Override definition in `ExperimentHelpers::Methods` to use Mongoid's
      # `desc` instead of ActiveRecord's `order`
      def variant_for(user)
        user_assigner = UserAssignment.new(user: user, experiment: self)
        variants.desc(:id)[user_assigner.variant_index]
      end
    end
  end
end
