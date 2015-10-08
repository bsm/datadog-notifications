datadog-notifications
=====================

Datadog intrumentation for [ActiveSupport::Notifications](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html).

## Installation

Add this line to your application's Gemfile:

    gem 'datadog-notifications'

Or install:

    $ gem install datadog-notifications

Configure it in an initializer:

    Datadog::Notifications.configure do |c|
      c.hostname = "my-host"
      c.tags     = ["my:tag"]

      c.use Datadog::Notifications::Plugins::ActionController
      c.use Datadog::Notifications::Plugins::ActiveRecord, tags: ["more:tags"]
    end

For full configuration options, please see the [Documentation](http://www.rubydoc.info/gems/datadog-notifications).

## Plugins

For a list of bundled plugins, please visit the [repository](https://github.com/bsm/datadog-notifications/tree/master/lib/datadog/notifications/plugins) page.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Make a pull request
