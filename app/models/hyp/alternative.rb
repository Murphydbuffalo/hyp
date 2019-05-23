module Hyp
  if Hyp.db_interface == :active_record
    class Alternative < ApplicationRecord
      belongs_to :experiment, foreign_key: 'hyp_experiment_id'
      has_many :experiment_user_trials, foreign_key: 'hyp_alternative_id', dependent: :destroy
    end
  elsif Hyp.db_interface == :mongoid
    class Alternative
      include Mongoid::Document
      include Mongoid::Timestamps

      belongs_to :experiment, class_name: 'Hyp::Experiment', foreign_key: 'hyp_experiment_id'
      has_many :experiment_user_trials, class_name: 'Hyp::ExperimentUserTrial', foreign_key: 'hyp_alternative_id', dependent: :destroy

      field :name, type: String
    end
  end
end
