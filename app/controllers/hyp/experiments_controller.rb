require_dependency "hyp/application_controller"

require 'hyp/services/experiment_creation'

module Hyp
  class ExperimentsController < ApplicationController
    before_action :set_experiment, only: [:show, :edit, :update, :destroy]

    def index
      limit  = params[:limit]  || 25
      offset = params[:offset] || 0

      @experiments = Experiment.offset(offset).limit(limit).includes(:alternatives)
    end

    def show
    end

    def new
      @experiment = Experiment.new
    end

    def edit
    end

    def create
      @experiment = Hyp::Services::ExperimentCreation.new(experiment_params).run

      if @experiment.valid?
        redirect_to @experiment, notice: 'Experiment was successfully created.'
      else
        render :new
      end
    end

    def update
      if @experiment.update(experiment_params)
        redirect_to @experiment, notice: 'Experiment was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @experiment.destroy
      redirect_to experiments_url, notice: 'Experiment was successfully destroyed.'
    end

    private

      def set_experiment
        @experiment = Experiment.find(params[:id])
      end

      def experiment_params
        params.require(:experiment).permit(:name,
                                           :alpha,
                                           :power,
                                           :control,
                                           :minimum_detectable_effect)
      end
  end
end
