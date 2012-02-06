# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "edploy"
  s.version     = "1.9.0"
  s.authors     = ["Ewout Vonk"]
  s.email       = ["dev@ewout.to"]
  s.homepage    = "https://github.com/ewoutvonk/edploy"
  s.summary     = %q{A gem which allows for fast, easy and efficient deploys with capistrano}
  s.description = %q{A gem which allows for fast, easy and efficient deploys with capistrano}

  s.rubyforge_project = "edploy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano"
end
