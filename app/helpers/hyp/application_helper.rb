module Hyp
  module ApplicationHelper
    include ActionView::Helpers::NumberHelper

    def number_to_percent(num)
      number_to_percentage(
        num * 100.0,
        strip_insignicicant_zeros: true,
        precision: 2
      )
    end
  end
end
