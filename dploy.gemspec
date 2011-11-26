# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "dploy"
  s.version     = "0.9.9"
  s.authors     = ["Ewout Vonk"]
  s.email       = ["dev@ewout.to"]
  s.homepage    = "https://github.com/ewoutvonk/dploy"
  s.summary     = %q{A gem which allows for fast, easy and efficient deploys with capistrano}
  s.description = %q{A gem which allows for fast, easy and efficient deploys with capistrano}

  s.rubyforge_project = "dploy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano"
  s.add_runtime_dependency "capistrano-catch-output"
  s.add_runtime_dependency "capistrano-deployment-tasks"
  s.add_runtime_dependency "capistrano-mailer"
  s.add_runtime_dependency "capistrano-minimal-output"
  s.add_runtime_dependency "capistrano-multistage"
  s.add_runtime_dependency "capistrano-optimized-git-deploy"
  s.add_runtime_dependency "capistrano-scoped-variables"
  s.add_runtime_dependency "capistrano-smart-deploy"
  s.add_runtime_dependency "capistrano-stacks"
  s.add_runtime_dependency "capistrano-variables-namespaces-list"
end
