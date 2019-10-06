# frozen_string_literal: true

require 'rails_helper'

describe Hyp::ExperimentUserTrialsController, controller: true do
  routes { Hyp::Engine.routes }

  let!(:exp) do
    Hyp::ExperimentRepo.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "Baby's first experiment"
    )
  end

  let(:idiot) do
    Idiot.create!(name: 'Dan', age: 29)
  end

  describe 'POST #create' do
    it 'creates a unique `ExperimentUserTrial` for the user' do
      expect {
        post :create,
          format: :json,
          params: {
            experiment_name: exp.name,
            user_identifier: idiot.id
          }
      }.to change { Hyp::ExperimentUserTrial.count }.by(1)

      expect {
        post :create,
          format: :json,
          params: {
            experiment_name: exp.name,
            user_identifier: idiot.id
          }
      }.not_to change { Hyp::ExperimentUserTrial.count }
    end
  end

  describe 'PATCH #convert' do
    let(:trial) do
      Hyp::ExperimentUserTrial.create!(
        experiment: exp,
        variant: exp.control_variant,
        user: idiot
      )
    end

    it 'marks an `ExperimentUserTrial` as converted' do
      expect {
        patch :convert,
          format: :json,
          params: {
            experiment_name: exp.name,
            user_identifier: idiot.id
          }
      }.to change { trial.reload && trial.converted? }.from(false).to(true)
    end
  end
end
