module Hyp
  class Engine < ::Rails::Engine
    isolate_namespace Hyp
    config.autoload_paths << File.expand_path('lib/hyp', __dir__)
  end
end
