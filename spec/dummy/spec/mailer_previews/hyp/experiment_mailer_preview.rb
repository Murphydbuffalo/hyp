module Hyp
  class ExperimentMailerPreview < ActionMailer::Preview
    def notify_experiment_done
      experiment = Hyp::ExperimentRepo.list.last || dummy_experiment
      Hyp::ExperimentMailer.notify_experiment_done(experiment.id, 'example-recipient@example.com')
    end

    private

      def dummy_experiment
        Hyp::Experiment.new(
          control: 0.10,
          minimum_detectable_effect: 0.02,
          name: 'Dummy experiment'
        )
      end
  end
end
