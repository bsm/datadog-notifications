ENV['RACK_ENV'] ||= 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'datadog-notifications'
require 'rspec'
require 'rack/test'
require 'grape'
require 'active_record'
require 'active_job'
require 'sqlite3'

### Active-record test preparation

ActiveRecord::Base.configurations = { 'test' => { 'adapter' => 'sqlite3', 'database' => ':memory:' } }
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.connection.create_table :posts do |t|
  t.string :title
end
class Post < ActiveRecord::Base
end

### ActiveJob test preparation

ActiveJob::Base.queue_adapter = :inline

### Configuration

RSpec.configure do |c|
  helpers = Module.new do
    def messages
      @messages ||= []
    end
  end

  c.include helpers
  c.before do
    # clear existing messages
    messages.clear

    # collect messages
    reporter = Datadog::Notifications.instance.send(:reporter)
    forwarder = reporter.send(:forwarder)
    allow(forwarder).to receive(:send_message) do |msg|
      @messages.push(msg)
    end

    # stub Time.now
    allow(Time).to receive(:now).and_return(
      Time.at(1616161616.161),
      Time.at(1616161616.272),
      Time.at(1616161616.948),
    )
  end
end

Datadog::Notifications.configure do |c|
  c.hostname = 'test.host'
  c.tags     = ['custom:tag']

  c.use Datadog::Notifications::Plugins::ActiveRecord
  c.use Datadog::Notifications::Plugins::ActiveJob
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
