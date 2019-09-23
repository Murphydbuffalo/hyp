module Hyp
  class ExperimentMailer < ApplicationMailer
    def notify_experiment_done(experiment_id, recipient)
      @experiment = Hyp::ExperimentRepo.find(experiment_id)

      mail(
        to: recipient,
        subject: "Hyp experiment #{@experiment.name} is done."
      )
    end
  end
end
