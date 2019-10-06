# frozen_string_literal: true

require 'rails_helper'

describe Hyp::ExperimentsController, controller: true do
  routes { Hyp::Engine.routes }

  let!(:exp1) do
    Hyp::ExperimentRepo.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "My first experiment"
    )
  end

  let!(:exp2) do
    Hyp::ExperimentRepo.create(
      alpha: 0.01,
      power: 0.90,
      control: 0.05,
      minimum_detectable_effect: 0.01,
      name: "My second experiment"
    )
  end

  describe 'GET #index' do
    render_views

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
end
