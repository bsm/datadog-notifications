require 'spec_helper'

describe Datadog::Notifications do

  subject { described_class.instance }
  after   { ActiveSupport::Notifications.unsubscribe(subscription) }

  let!(:subscription) do
    subject.subscribe('mock.perform') do |reporter, event|
      status = event.payload[:status]
      method = event.payload[:method]
      tags   = ["status:#{status}", "method:#{method}"]

      reporter.batch do
        reporter.increment 'web.render', tags: tags
        reporter.timing 'web.render.time', event.duration, tags: tags
      end
    end
  end

  it 'should have a reporter' do
    expect(subject.send(:reporter)).to be_instance_of(Mock::Reporter)
  end

  it 'should subscribe and report' do
    Mock::Instrumentable.new(method: 'GET').perform
    expect(buffered).to eq([
      'web.render:1|c|#custom:tag,env:test,host:test.host,status:200,method:GET',
      'web.render.time:333|ms|#custom:tag,env:test,host:test.host,status:200,method:GET',
    ])
  end

end
