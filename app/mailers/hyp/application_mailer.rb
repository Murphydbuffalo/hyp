# frozen_string_literal: true

module Hyp
  class ApplicationMailer < ActionMailer::Base
    layout 'hyp/mailer'
    default from: 'no-reply@hyp.works'
  end
end
