require 'digest'

module Experiments
  class UserAssignment
    def initialize(identifier:, alternatives:)
      @identifier   = identifier.to_s
      @alternatives = alternatives
    end

    def index
      int % alternatives.length
    end

    private

    def int
      @int ||= Digest::SHA256.hexdigest(identifier).to_i
    end

    attr_reader :identifier, :alternatives
  end
end
