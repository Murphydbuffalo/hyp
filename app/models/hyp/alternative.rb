module Hyp
  class Alternative < ApplicationRecord
    belongs_to :experiment, foreign_key: 'hyp_experiment_id'
    has_many  :experiment_user_trials, foreign_key: 'hyp_alternative_id', dependent: :destroy
  end
end
