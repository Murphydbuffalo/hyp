require_dependency "hyp/application_controller"
require 'hyp/experiment_repo'

module Hyp
  class ExperimentsController < ApplicationController
    before_action :http_basic_authenticate, if: -> { Rails.env.production? }
    before_action :set_experiment, only: [:show, :edit, :update, :destroy]
    before_action :redirect_to_experiment_show_if_experiment_started, only: [:edit, :update]

    def index
      limit  = params[:limit]  || 25
      offset = params[:offset] || 0

      @experiments = ExperimentRepo.list
    end

    def show
    end

    def new
      @experiment = Experiment.new
    end

    def edit
    end

    def create
      @experiment = ExperimentRepo.create(experiment_params)

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
        @experiment = ExperimentRepo.find(params[:id])
      end

      def experiment_params
        params.require(:experiment).permit(:name,
                                           :alpha,
                                           :power,
                                           :control,
                                           :minimum_detectable_effect)
      end

      def http_basic_authenticate
        http_basic_authenticate_with name: ENV['HYP_USERNAME'], password: ENV['HYP_PASSWORD']
      end

      def redirect_to_experiment_show_if_experiment_started
        if @experiment.started?
          redirect_to(
            @experiment,
            notice: 'Cannot modify an experiment that has already started'
          )
        end
      end
  end
end
