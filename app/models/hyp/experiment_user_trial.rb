module Hyp
  if Hyp.db_interface == :active_record
    class ExperimentUserTrial < ApplicationRecord
      extend Hyp::ExperimentUserTrialHelpers::Callbacks

      belongs_to :experiment, foreign_key: 'hyp_experiment_id'
      belongs_to :variant,    foreign_key: 'hyp_variant_id'
      belongs_to :user,       foreign_key: Hyp.user_foreign_key_name, class_name: Hyp.user_class_name
    end
  elsif Hyp.db_interface == :mongoid
    class ExperimentUserTrial
      include Mongoid::Document
      include Mongoid::Timestamps
      extend Hyp::ExperimentUserTrialHelpers::Callbacks

      belongs_to :experiment, class_name: 'Hyp::Experiment',   foreign_key: 'hyp_experiment_id'
      belongs_to :variant,    class_name: 'Hyp::Variant',      foreign_key: 'hyp_variant_id'
      belongs_to :user,       class_name: Hyp.user_class_name, foreign_key: Hyp.user_foreign_key_name

      field :converted, type: Boolean, default: false

      index({ hyp_experiment_id: 1, Hyp.user_foreign_key_name => 1 }, { unique: true })
    end
  end
end
