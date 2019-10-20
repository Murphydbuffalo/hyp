# frozen_string_literal: true

require 'hyp/user_assignment'

describe Hyp::UserAssignment do
  describe '#variant_index' do
    let(:user_a) do
      double('User', id: 1)
    end

    let(:experiment_a) do
      double('Experiment', id: 1, variants: [double, double])
    end

    let(:user_b) do
      double('User', id: 5)
    end

    let(:experiment_b) do
      double('Experiment', id: 2, variants: [double, double])
    end

    it 'always returns the same index for the same user and experiment' do
      10.times do
        index1 = described_class.new(user: user_a, experiment: experiment_a).variant_index
        expect(index1).to be 0

        index2 = described_class.new(user: user_b, experiment: experiment_b).variant_index
        expect(index2).to be 1
      end
    end

    it 'evenly distributes users between experiment variants' do
      assignments = (0..1_000).each_with_object({}) do |i, hash|
        user  = double("User #{i}", id: i)
        index = described_class.new(user: user, experiment: experiment_a).variant_index

        hash[index] ||= 0
        hash[index]  += 1
      end

      diff = (assignments[0] - assignments[1]).abs

      expect(diff).to be < 10
    end
  end
end
