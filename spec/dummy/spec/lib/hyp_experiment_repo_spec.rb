# frozen_string_literal: true

require 'rails_helper'
require '../../lib/hyp/experiment_repo'

describe Hyp::ExperimentRepo do
  let!(:exp) do
    described_class.create(
      alpha: 0.05,
      power: 0.80,
      control: 0.05,
      minimum_detectable_effect: 0.05,
      name: "Baby's first experiment"
    )
  end

  describe '#create' do
    it 'returns creates an experiment with control and treatment variants' do
      expect(exp).to be_persisted
      expect(exp.variants.map(&:name)).to match_array(%w[Control Treatment])
    end
  end

  describe '#list' do
    before do
      25.times do |i|
        described_class.create(
          alpha: 0.05,
          power: 0.80,
          control: 0.05,
          minimum_detectable_effect: 0.05,
          name: "Experiment #{i}"
        )
      end
    end

    it 'returns an array of 25 experiments' do
      expect(Hyp::Experiment.count).to be 26

      list = described_class.list
      expect(list.count).to be 25
      list.each do |exp|
        expect(exp).to be_a(Hyp::Experiment)
      end
    end

    context 'limiting' do
      it 'returns an array of `limit` experiments' do
        list = described_class.list(limit: 10)
        expect(list.count).to be 10
      end
    end

    context 'offsetting and limiting' do
      it 'returns an array of `limit` experiments after skipping `offset` experiments' do
        no_offset_list = described_class.list(limit: 10)
        list = described_class.list(limit: 10, offset: 5)

        expect(list.count).to be 10
        expect(list[0..4]).to eq no_offset_list[5..9]
      end
    end
  end

  describe '#find' do
    it 'retrieves an experiment by ID' do
      expect(described_class.find(exp.id)).to eq exp
    end
  end

  describe '#find_by' do
    it 'retrieves an experiment by an arbitrary query' do
      expect(described_class.find_by(name: exp.name)).to eq exp
    end
  end
end
