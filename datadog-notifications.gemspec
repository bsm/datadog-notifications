# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog/notifications/version'

Gem::Specification.new do |s|
  s.name          = "datadog-notifications"
  s.version       = Datadog::Notifications::VERSION.dup
  s.authors       = ["Dimitrij Denissenko"]
  s.email         = ["dimitrij@blacksquaremedia.com"]
  s.description   = %q{Datadog instrumnetation for ActiveSupport::Notifications}
  s.summary       = %q{Generic ActiveSupport::Notifications Datadog handler}
  s.homepage      = "https://github.com/bsm/datadog-notifications"

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<activesupport>)
  s.add_runtime_dependency(%q<dogstatsd-ruby>, "~> 3.1")

  s.add_development_dependency(%q<rack-test>)
  s.add_development_dependency(%q<grape>, ">= 0.16")
  s.add_development_dependency(%q<sqlite3>)
  s.add_development_dependency(%q<activerecord>)
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<bundler>)
  s.add_development_dependency(%q<rspec>)
end
