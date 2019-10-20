# frozen_string_literal: true

require '../../lib/hyp/experiment_repo'

describe Hyp::ExperimentUserTrial do
  let(:exp) do
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

  before do
    allow_any_instance_of(Hyp::Experiment).to receive(:finished?) { true }
    Hyp.experiment_complete_callback = ->(experiment_id) { Hyp::ExperimentRepo.find(experiment_id) }
  end

  describe '.after_create' do
    it 'invokes the code in `Hyp.experiment_complete_callback`' do
      expect(Hyp::ExperimentRepo).to receive(:find).with exp.id
      exp.record_trial(idiot)
    end
  end
end
