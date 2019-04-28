# Can probably get rid of this... just need to test on a Rails app tbat uses
# ActiveRecord instead of Mongoid
# require_dependency 'active_record/base'

module Hyp
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
