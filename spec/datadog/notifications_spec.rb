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

  it 'has a reporter' do
    expect(subject.send(:reporter)).to be_instance_of(Datadog::Notifications::Reporter)
  end

  it 'subscribes and report' do
    klass = Class.new do
      def initialize(**opts)
        @opts = opts
      end

      def perform
        ActiveSupport::Notifications.instrument('mock.start', @opts)
        ActiveSupport::Notifications.instrument('mock.perform', @opts) do |payload|
          payload[:status] = 200
        end
      end
    end
    klass.new(method: 'GET').perform

    expect(messages).to eq([
      'web.render:1|c|#custom:tag,env:test,host:test.host,status:200,method:GET',
      'web.render.time:111.0|ms|#custom:tag,env:test,host:test.host,status:200,method:GET',
    ])
  end
end
