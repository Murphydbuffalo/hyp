module Hyp
  class Experiment < ApplicationRecord
    has_many  :alternatives, foreign_key: 'hyp_experiment_id', dependent: :destroy
    validates :alpha, inclusion: { in: [0.05, 0.01] }
    validates :power, inclusion: { in: [0.80, 0.90] }
    validates :control, numericality: { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates :minimum_detectable_effect, numericality: { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
    validates_uniqueness_of :name
  end
end
