module Hyp
  module ExperimentHelpers
    module Validations
      def self.extended(extending_class)
        extending_class.instance_eval(
          <<-RUBY
            validates :alpha, inclusion: { in: [0.05, 0.01] }
            validates :power, inclusion: { in: [0.80, 0.90] }
            validates :control, numericality:
              { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
            validates :minimum_detectable_effect, numericality:
              { less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0 }
            validates_uniqueness_of :name
            validates_presence_of :name
          RUBY
        )
      end
    end
  end
end
