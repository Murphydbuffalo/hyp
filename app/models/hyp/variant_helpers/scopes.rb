module Hyp
  module VariantHelpers
    module Scopes
      def self.extended(extending_class)
        extending_class.instance_eval(
          <<-RUBY
            scope :control,   ->{ where(name: 'Control') }
            scope :treatment, ->{ where(name: 'Treatment') }
          RUBY
        )
      end
    end
  end
end
