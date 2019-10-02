require_dependency 'active_record/base'

module Hyp
  class ApplicationRecord < ::ActiveRecord::Base
    self.abstract_class = true
  end
end
