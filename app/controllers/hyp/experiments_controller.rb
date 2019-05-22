require 'hyp/services/experiment_creation'

module Hyp
  # We do not call `require_dependency 'hyp/application_controller'`
  # because we want to inherit from the mounting application's
  # `ApplicationController`. This allows us to leverage whatever authorization
  # method they've specified in `Hyp.authorize_with`.
  class ExperimentsController < ::ApplicationController
    before_action :authorize
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

      def authorize
        return if authorized?

        redirect_back(
          fallback_location: main_app.root_path,
          notice: 'Forbidden'
        )
      end

      def authorized?
        return true unless respond_to?(Hyp.authorize_with.to_s)
        send(Hyp.authorize_with)
      end
  end
end
