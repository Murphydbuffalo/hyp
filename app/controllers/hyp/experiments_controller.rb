require_dependency "hyp/application_controller"

require 'hyp/statistics/sample_size'

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
      # TODO: Extract this into a service so we can be database-agnostic
      @experiment = Experiment.new(experiment_params)
      @experiment.sample_size = Hyp::Statistics::SampleSize.new(
        alpha:                     @experiment.alpha,
        power:                     @experiment.power,
        control:                   @experiment.control,
        minimum_detectable_effect: @experiment.minimum_detectable_effect
      )

      ActiveRecord::Base.transaction do
        @experiment.save
        @experiment.alternatives.create(alternatives_params)
      end

      if @experiment.valid?
        redirect_to @experiment, notice: 'Experiment was successfully created.'
      else
        render :new
      end
    end

    # Record trials and conversions IF the alternative isn't finished
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

    def alternatives_params
      [
        {
          name: 'Control'
        },
        {
          name: 'Treatment'
        }
      ]
    end
  end
end
