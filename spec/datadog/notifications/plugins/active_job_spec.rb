require 'spec_helper'

describe Datadog::Notifications::Plugins::ActiveJob do
  it 'sanitizes tags' do
    klass = Class.new(ActiveJob::Base) do
      def self.name
        'Mock::NoopJob'
      end

      self.queue_name = 'test:queue'
      def perform; end
    end

    klass.perform_now
    expect(messages).to eq [
      'activejob.perform:1|c|#custom:tag,env:test,host:test.host,job:mock/noop,queue:test_queue',
      'activejob.perform.time:787.0|ms|#custom:tag,env:test,host:test.host,job:mock/noop,queue:test_queue',
    ]
  end
end
