module Hyp
  if Hyp.db_interface == :active_record
    class Variant < ApplicationRecord
      include Hyp::VariantHelpers::Methods
      extend  Hyp::VariantHelpers::Scopes

      belongs_to :experiment, foreign_key: 'hyp_experiment_id'
      has_many :experiment_user_trials, foreign_key: 'hyp_variant_id', dependent: :destroy
    end
  elsif Hyp.db_interface == :mongoid
    class Variant
      include Mongoid::Document
      include Mongoid::Timestamps
      include Hyp::VariantHelpers::Methods
      extend  Hyp::VariantHelpers::Scopes

      belongs_to :experiment, class_name: 'Hyp::Experiment', foreign_key: 'hyp_experiment_id'
      has_many :experiment_user_trials, class_name: 'Hyp::ExperimentUserTrial', foreign_key: 'hyp_variant_id', dependent: :destroy

      field :name, type: String
    end
  end
end
