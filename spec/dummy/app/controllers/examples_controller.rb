class ExamplesController < ::ApplicationController
  before_action :set_experiment
  before_action :set_user

  def index
    if params[:hyp]
      Hyp::QueryParam.record_event_for(params[:hyp])

      trial           = Hyp::ExperimentUserTrial.last
      flash[:success] = "#{@user.name} participated in the #{@experiment.name} experiment, which now has #{@experiment.experiment_user_trials.count} particpants, #{@experiment.experiment_user_trials.where(converted: true).count} of which have converted."
    elsif params[:run_experiment]
      Hyp::ExperimentRunner.run(
        @experiment.name,
        user: @user,
        control:   -> { flash[:success] = "Executing control variant code for #{@user.name}" },
        treatment: -> { flash[:success] = "Executing treatment variant code for #{@user.name}" }
      )
    end
  end

    private

    def set_experiment
      @experiment = Hyp::ExperimentRepo.list.first
    end

    def set_user
      @user = Idiot.first
    end
end
