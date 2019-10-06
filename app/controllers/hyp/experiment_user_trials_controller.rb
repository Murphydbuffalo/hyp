# frozen_string_literal: true

require_dependency "hyp/application_controller"
require 'hyp/experiment_repo'

module Hyp
  class ExperimentUserTrialsController < ApplicationController
    before_action :set_experiment
    before_action :set_user

    def create
      respond_to do |format|
        format.json do
          if @experiment.record_trial(@user)
            render json: 'Success', status: 200
          else
            render json: 'Failure', status: 400
          end
        end
      end
    end

    def convert
      respond_to do |format|
        format.json do
          if @experiment.record_conversion(@user)
            render json: 'Success', status: 200
          else
            render json: 'Failure', status: 400
          end
        end
      end
    end

    private

      def set_experiment
        @experiment = ExperimentRepo.find_by(name: params[:experiment_name])
      end

      def set_user
        @user = Hyp.user_class.find(params[:user_identifier])
      end
  end
end
