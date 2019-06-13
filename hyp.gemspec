$:.push File.expand_path("lib", __dir__)

require "hyp/version"

Gem::Specification.new do |spec|
  spec.name        = "hyp"
  spec.version     = Hyp::VERSION
  spec.authors     = ["Dan Murphy"]
  spec.email       = ["hello@danmurphy.codes"]
  spec.homepage    = "https://hyp.works/"
  spec.summary     = "Minimal configuration, statistically valid A/B testing for Ruby on Rails."
  spec.description = "Easily run, monitor, and understand A/B tests from your Rails app."
  spec.license     = "MIT"
  spec.post_install_message = "Hyyyyyyyyyyp!"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails"
  spec.add_development_dependency "rspec-rails"
end
