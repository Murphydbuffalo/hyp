# frozen_string_literal: true

require_dependency "hyp/application_controller"

module Hyp
  class SampleSizesController < ApplicationController
    include ActionView::Helpers::NumberHelper

    def show
      @experiment = Hyp::Experiment.new(
        alpha:                     params[:alpha],
        power:                     params[:power],
        control:                   params[:control],
        minimum_detectable_effect: params[:minimum_detectable_effect]
      )

      respond_to do |format|
        format.json do
          if @experiment.sample_size
            render json: { result: number_with_delimiter(@experiment.sample_size) }, status: 200
          else
            render json: { result: 'Please specify alpha, power, control, and MDE.' }, status: 400
          end
        end
      end
    end
  end
end
