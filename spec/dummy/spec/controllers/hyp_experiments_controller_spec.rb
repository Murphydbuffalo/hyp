# frozen_string_literal: true

require 'rails_helper'

describe Hyp::ExperimentsController, controller: true do
  include ActionView::Helpers::NumberHelper
  routes { Hyp::Engine.routes }
  render_views

  let(:exp1) do
    Hyp::ExperimentRepo.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "My first experiment"
    )
  end

  let(:exp2) do
    Hyp::ExperimentRepo.create(
      alpha: 0.01,
      power: 0.90,
      control: 0.05,
      minimum_detectable_effect: 0.01,
      name: "My second experiment"
    )
  end

  describe 'GET #index' do
    before do
      exp1
      exp2
    end

    it 'returns a paginated list of experiments' do
      get :index

      expect(response.body).to include exp1.name
      expect(response.body).to include exp2.name

      get :index, params: { limit: 1 }

      expect(response.body).to include exp1.name
      expect(response.body).not_to include exp2.name

      get :index, params: { offset: 1 }

      expect(response.body).not_to include exp1.name
      expect(response.body).to include exp2.name
    end
  end

  describe 'GET #show' do
    before do
      exp1
    end

    it 'returns a detailed view of an experiment' do
      get :show, params: { id: exp1.id }
      expect(response.body).to include exp1.name
      expect(response.body).to include exp1.alpha.to_s
      expect(response.body).to include exp1.power.to_s
      expect(response.body).to include exp1.control.to_s
      expect(response.body).to include exp1.minimum_detectable_effect.to_s
      expect(response.body).to include number_with_delimiter(exp1.sample_size)
    end
  end

  describe 'GET #new' do
    it 'returns a detailed view of an experiment' do
      get :new
      expect(response.body).to include 'Learn more about sample size calculations.'
    end
  end

  describe 'POST #create' do
    it 'creates a new experiment' do
      expect {
        post :create, params: {
          experiment: {
            alpha: 0.05,
            power: 0.80,
            control: 0.12,
            minimum_detectable_effect: 0.02,
            name: 'A wonderful experiment'
          }
        }
      }.to change { Hyp::Experiment.count }.by(1)
    end
  end
end
