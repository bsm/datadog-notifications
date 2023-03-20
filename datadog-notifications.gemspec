lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog/notifications/version'

Gem::Specification.new do |s|
  s.name          = 'datadog-notifications'
  s.version       = Datadog::Notifications::VERSION.dup
  s.authors       = ['Dimitrij Denissenko']
  s.email         = ['dimitrij@blacksquaremedia.com']
  s.description   = 'Datadog instrumentation for ActiveSupport::Notifications'
  s.summary       = 'Generic ActiveSupport::Notifications Datadog handler'
  s.homepage      = 'https://github.com/bsm/datadog-notifications'

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'dogstatsd-ruby', '>= 5.0'

  s.metadata['rubygems_mfa_required'] = 'true'
end
