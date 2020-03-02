module Hyp
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    content_security_policy do |p|
      asset_host = Rails.application.config.asset_host

      p.script_src :self, :unsafe_inline, '*.fontawesome.com', asset_host.to_s
      p.style_src :self, :unsafe_inline, '*.fontawesome.com',  asset_host.to_s
      p.font_src :self, '*.fontawesome.com'
    end
  end
end
