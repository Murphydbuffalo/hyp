# frozen_string_literal: true

require 'hyp/experiment_repo'

module Hyp
  class QueryParam
    def self.record_event_for(encoded_string)
      Parser.new(encoded_string).record_event
    end

    def initialize(user:, experiment:, event_type:)
      @user       = user
      @experiment = experiment
      @event_type = event_type
    end

    def record_event
      case event_type
      when 'conversion'
        experiment.record_conversion(user)
      when 'trial'
        experiment.record_trial(user)
      end
    end

    def to_s
      Base64.strict_encode64("#{experiment.id}:#{user.id}:#{event_type}")
    end

    private

      attr_reader :user, :experiment, :event_type

      class Parser
        def initialize(encoded_string)
          @encoded_string = encoded_string
        end

        def record_event
          query_param.record_event if valid_string?
        end

        private

          attr_reader :encoded_string

          def valid_string?
            decoded.present? && event_type.in?(%w[conversion trial])
          rescue
            false
          end

          def query_param
            QueryParam.new(
              experiment: experiment,
              user:       user,
              event_type: event_type
            )
          end

          def experiment
            @experiment ||= Hyp::ExperimentRepo.find(experiment_id)
          end

          def user
            @user ||= Hyp.user_class.find(user_id)
          end

          def event_type
            @event_type ||= components.third
          end

          def experiment_id
            components.first
          end

          def user_id
            components.second
          end

          def components
            decoded.split(':')
          end

          def decoded
            @decoded ||= Base64.decode64(encoded_string)
          end
    end
  end
end
