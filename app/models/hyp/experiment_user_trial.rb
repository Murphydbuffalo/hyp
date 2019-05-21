module Hyp
  class ExperimentUserTrial < ApplicationRecord
    belongs_to :experiment, foreign_key: 'hyp_experiment_id'
    belongs_to :alternative, foreign_key: 'hyp_alternative_id'

    # This is not an ActiveRecord association because we don't know if the
    # mounting application will keep its A/B test data in the same datastore
    # as its user data.
    validates_uniqueness_of :user_id
  end
end
