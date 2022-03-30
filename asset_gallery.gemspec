$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "asset_gallery/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "asset_gallery"
  s.version     = AssetGallery::VERSION
  s.authors     = ["Eric Richardson"]
  s.email       = ["e@ericrichardson.com"]
  s.homepage    = "http://ericrichardson.com"
  s.summary     = "Easy galleries of photos and more built on top of AssetHost."
  s.description = "Easy galleries of photos and more built on top of AssetHost."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "kaminari"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
