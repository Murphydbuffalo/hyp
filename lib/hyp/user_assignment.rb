# frozen_string_literal: true

require 'digest'

module Hyp
  class UserAssignment
    def initialize(user:, experiment:)
      @user       = user
      @experiment = experiment
    end

    def variant_index
      user_experiment_hash.to_i(16) % num_variants
    end

    private

    attr_reader :user, :experiment

    def user_experiment_hash
      @user_experiment_hash ||=
        Digest::SHA256.hexdigest(user.id.to_s + experiment.id.to_s)
    end

    def num_variants
      experiment.variants.count
    end
  end
end
