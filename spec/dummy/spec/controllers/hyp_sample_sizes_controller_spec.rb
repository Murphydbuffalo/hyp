# frozen_string_literal: true

describe Hyp::SampleSizesController, controller: true do
  routes { Hyp::Engine.routes }

  describe 'GET #show' do
    it 'returns a formatted string representation of the sample size' do
      get :show, format: :json, params: {
        alpha: 0.05,
        power: 0.90,
        control: 0.02,
        minimum_detectable_effect: 0.01
      }

      result = JSON.parse(response.body)['result']
      expect(result).to eq '5,321'
    end
  end
end
