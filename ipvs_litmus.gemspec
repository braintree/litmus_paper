# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ipvs_litmus/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Braintreeps"]
  gem.email         = ["code@getbraintree.com"]
  gem.description   = %q{Backend health tester for HA Services}
  gem.summary       = %q{Backend health tester for HA Services}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ipvs_litmus"
  gem.require_paths = ["lib"]
  gem.version       = IPVSLitmus::VERSION

  gem.add_dependency "sinatra", "~> 1.3.2"
  gem.add_dependency "facter", "~> 1.6.7"

  gem.add_development_dependency "rspec", "2.9.0"
  gem.add_development_dependency "rack-test", "0.6.1"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rake_commit", "0.13"
end
