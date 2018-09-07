
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog/notifications/version'

Gem::Specification.new do |s|
  s.name          = "datadog-notifications"
  s.version       = Datadog::Notifications::VERSION.dup
  s.authors       = ["Dimitrij Denissenko"]
  s.email         = ["dimitrij@blacksquaremedia.com"]
  s.description   = 'Datadog instrumentation for ActiveSupport::Notifications'
  s.summary       = 'Generic ActiveSupport::Notifications Datadog handler'
  s.homepage      = "https://github.com/bsm/datadog-notifications"

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency('activesupport')
  s.add_runtime_dependency('dogstatsd-ruby', "~> 3.1")

  s.add_development_dependency('activerecord')
  s.add_development_dependency('bundler')
  s.add_development_dependency('grape', ">= 0.16")
  s.add_development_dependency('rack-test')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('sqlite3')
end
