require 'digest'

module Hyp
  class UserAssignment
    def initialize(user:, alternatives:)
      @user         = user
      @alternatives = alternatives
    end

    def index
      int % alternatives.length
    end

    private

    def int
      @int ||= Digest::SHA256.hexdigest(user.id.to_s).to_i(16)
    end

    attr_reader :user, :alternatives
  end
end
