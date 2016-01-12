$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comfortable_mexican_loveseat"
  s.version     = "0.0.21"
  s.authors     = ["Adam Bahlke", "Michael Rüffer"]
  s.email       = ["adam.bahlke@hitfoxgroup.com"]
  s.homepage    = "http://hitfoxgroup.com"
  s.summary     = "An expansion of the Comfortable Mexican Sofa, to make your living room comfier."
  s.description = "Comfortable Mexican Loveseat expands the Comfortable Mexican Sofa with additional helpers and features"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0"
  s.add_dependency "comfortable_mexican_sofa", "~> 1.12.8"
  s.add_dependency "rack-rewrite", "~> 1.5.1"
  s.add_dependency "rubyzip", "~>1.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bundler", "~> 1.9"
  s.add_development_dependency "rake", "~> 10.0"
end
