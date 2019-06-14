module Hyp
  module AlternativeHelpers
    module Methods
      def control?
        name == 'Control'
      end

      def treatment?
        name == 'Treatment'
      end
    end
  end
end
