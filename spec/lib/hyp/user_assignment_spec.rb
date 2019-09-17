# frozen_string_literal: true

require 'rspec'
require 'hyp/user_assignment'

describe Hyp::UserAssignment do
  describe '#alternative_index' do
    let(:user_a) do
      double('User', id: 1)
    end

    let(:experiment_a) do
      double('Experiment', id: 1, alternatives: [double, double])
    end

    let(:user_b) do
      double('User', id: 5)
    end

    let(:experiment_b) do
      double('Experiment', id: 2, alternatives: [double, double])
    end

    it 'always returns the same index for the same user and experiment' do
      10.times do
        index1 = described_class.new(user: user_a, experiment: experiment_a).alternative_index
        expect(index1).to be 0

        index2 = described_class.new(user: user_b, experiment: experiment_b).alternative_index
        expect(index2).to be 1
      end
    end
  end
end
