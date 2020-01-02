ENV['RACK_ENV'] ||= 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'datadog-notifications'
require 'rspec'
require 'rack/test'
require 'grape'
require 'active_record'
require 'sqlite3'

### Active-record test preparation

ActiveRecord::Base.configurations = { 'test' => { 'adapter' => 'sqlite3', 'database' => ':memory:' } }
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.connection.create_table :posts do |t|
  t.string :title
end
class Post < ActiveRecord::Base
end

### Mocks

module Mock
  class Reporter < Datadog::Notifications::Reporter
    def timing(stat, _millis, opts={})
      super(stat, 333, opts)
    end

    def send_stat(message)
      messages.push message
    end

    def messages
      @messages ||= []
    end
  end

  class Instrumentable
    def initialize(opts={})
      @opts = opts
    end

    def perform
      ActiveSupport::Notifications.instrument('mock.start', @opts)
      ActiveSupport::Notifications.instrument('mock.perform', @opts) do |payload|
        payload[:status] = 200
      end
    end
  end
end

### Configuration

RSpec.configure do |c|
  helpers = Module.new do
    def buffered
      Datadog::Notifications.instance.send(:reporter).messages
    end
  end

  c.include helpers
  c.before do
    buffered.clear
  end
end

Datadog::Notifications.configure do |c|
  c.hostname = 'test.host'
  c.reporter = Mock::Reporter
  c.tags     = ['custom:tag']

  c.use Datadog::Notifications::Plugins::ActiveRecord
  c.use Datadog::Notifications::Plugins::Grape,
    tags: ['more:tags'],
    metric_name: 'api.request',
    exception_handler: lambda {|e|
      if e.message.include?('unauthorized')
        401
      else
        Datadog::Notifications::Plugins::Grape.exception_status(e)
      end
    }
end
