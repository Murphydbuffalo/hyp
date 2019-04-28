module Hyp
  class Experiment < ApplicationRecord
    has_many  :alternatives, foreign_key: 'hyp_experiment_id', dependent: :destroy
    validates :alpha, inclusion: { in: [0.05, 0.01] }
    validates :power, inclusion: { in: [0.80, 0.90] }
    validates_uniqueness_of :name
  end
end
