require 'spec_helper'

describe Datadog::Notifications::Plugins::ActiveJob do
  it 'sanitizes tags' do
    NoopJob.perform_now
    expect(buffered).to eq [
      'activejob.perform:1|c|#custom:tag,env:test,host:test.host,job:noop,queue:test_queue',
      'activejob.perform.time:333|ms|#custom:tag,env:test,host:test.host,job:noop,queue:test_queue',
    ]
  end
end
