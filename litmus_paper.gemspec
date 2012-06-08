# -*- encoding: utf-8 -*-
require File.expand_path('../lib/litmus_paper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Braintreeps"]
  gem.email         = ["code@getbraintree.com"]
  gem.description   = %q{Backend health tester for HA Services}
  gem.summary       = %q{Backend health tester for HA Services, partner project of big_brother}
  gem.homepage      = "https://github.com/braintree/litmus_paper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "litmus_paper"
  gem.require_paths = ["lib"]
  gem.version       = LitmusPaper::VERSION

  gem.required_ruby_version = '>= 1.9.1'

  gem.add_dependency "thin", "~> 1.3.1"
  gem.add_dependency "async-rack", "~> 0.5.1"
  gem.add_dependency "sinatra", "~> 1.3.2"
  gem.add_dependency "rack-fiber_pool", "~> 0.9"
  gem.add_dependency "facter", "~> 1.6.7"
  gem.add_dependency "eventmachine",      "> 1.0.0.beta.1", "< 1.0.0.beta.100"
  gem.add_dependency "em-http-request",   "~> 1.0"
  gem.add_dependency "em-synchrony",      "~> 1.0"
  gem.add_dependency "em-resolv-replace", "~> 1.1"
  gem.add_dependency "em-syslog",         "~> 0.0.2"

  gem.add_development_dependency "rspec", "2.9.0"
  gem.add_development_dependency "rack-test", "0.6.1"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rake_commit", "0.13"
end
