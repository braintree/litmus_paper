# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require "litmus_paper/version"

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

  gem.add_dependency "sinatra", "~> 1.3.2"
  gem.add_dependency "remote_syslog_logger", "~> 1.0.3"
  gem.add_dependency "unicorn", "~> 4.6.2"
  gem.add_dependency "colorize"
  gem.add_dependency "json", "~> 2.1.0"

  gem.add_development_dependency "rspec", "~> 2.9.0"
  gem.add_development_dependency "rack-test", "~> 0.6.1"
  gem.add_development_dependency "rake", "~> 0.9.2.2"
  gem.add_development_dependency "rake_commit", "~> 0.13"
end
