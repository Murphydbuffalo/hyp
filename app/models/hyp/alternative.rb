module Hyp
  class Alternative < ApplicationRecord
    belongs_to :experiment, foreign_key: 'hyp_experiment_id'
  end
end
