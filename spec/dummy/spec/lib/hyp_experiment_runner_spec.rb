# frozen_string_literal: true

require 'rails_helper'
require '../../lib/hyp/experiment_runner'

describe Hyp::ExperimentRunner do
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

  describe '.run' do
    context 'the user belongs to the control variant' do
      before do
        allow_any_instance_of(Hyp::Variant).to receive(:treatment?) { false }
      end

      it 'executes the `control` block of code' do
        expect(idiot).to receive(:name)

        described_class.run(
          exp.name,
          user: idiot,
          control: -> { idiot.name },
          treatment: -> { idiot.age }
        )
      end
    end

    context 'the user belongs to the treatment variant' do
      before do
        allow_any_instance_of(Hyp::Variant).to receive(:treatment?) { true }
      end

      it 'executes the `treatment` block of code' do
        expect(idiot).to receive(:age)

        described_class.run(
          exp.name,
          user: idiot,
          control: -> { idiot.name },
          treatment: -> { idiot.age }
        )
      end
    end

    context 'the `record_trial` argument is set to `true`' do
      it 'executes the `control` block of code' do
        expect {
          described_class.run(
            exp.name,
            user: idiot,
            control: -> { idiot.name },
            treatment: -> { idiot.age },
            record_trial: true
          )
        }.to change { Hyp::ExperimentUserTrial.count }.by(1)
      end
    end

    context 'no experiment is found' do
      it 'executes the control block' do
        expect(idiot).to receive(:name)

        described_class.run(
          "This is not the experiment you're looking for",
          user: idiot,
          control: -> { idiot.name },
          treatment: -> { idiot.age }
        )
      end
    end
  end
end
