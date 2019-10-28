# frozen_string_literal: true

module Hyp
  class Engine < ::Rails::Engine
    require 'jquery/rails'
    isolate_namespace Hyp
    config.autoload_paths << File.expand_path('lib/hyp', __dir__)
  end
end
