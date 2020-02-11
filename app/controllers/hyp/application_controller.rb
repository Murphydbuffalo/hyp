module Hyp
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    content_security_policy do |p|
      p.script_src :self, :unsafe_inline, '*.fontawesome.com'
      p.style_src :self, :unsafe_inline, '*.fontawesome.com'
      p.font_src :self, '*.fontawesome.com'
    end
  end
end
