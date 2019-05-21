require_dependency "hyp/application_controller"

module Hyp
  class ExperimentUserTrialsController < ApplicationController
    before_action :set_experiment

    def create
      respond_to do |format|
        format.json do
          if @experiment.record_trial(params[:user_identifier])
            render json: 'Success', status: 200
          else
            render json: 'Failure', status: 400
          end
        end
      end
    end

    def update
      respond_to do |format|
        format.json do
          if @experiment.record_conversion(params[:user_identifier])
            render json: 'Success', status: 200
          else
            render json: 'Failure', status: 400
          end
        end
      end
    end

    private

      def set_experiment
        @experiment = Experiment.find_by(name: params[:name])
      end
  end
end
