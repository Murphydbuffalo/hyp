module Hyp
  class ExperimentUserTrial < ApplicationRecord
    belongs_to :experiment,  foreign_key: 'hyp_experiment_id'
    belongs_to :alternative, foreign_key: 'hyp_alternative_id'
    belongs_to :user,        foreign_key: Hyp.user_foreign_key_name, class_name: Hyp.user_class_name
  end
end
