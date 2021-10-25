$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "prismic_document/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "prismic_document"
  spec.version     = PrismicDocument::VERSION
  spec.authors     = ["sarco3t"]
  spec.email       = ["14gainward88@gmail.com"]
  # spec.homepage    = "TODO"
  spec.summary     = "Summary of PrismicDocument."
  spec.description = "Description of PrismicDocument."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency 'rack-proxy', '~> 0.6.4'
  spec.add_dependency 'prismic.io'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'coderay'

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rubocop"
end
