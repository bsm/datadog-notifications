require 'spec_helper'

describe Datadog::Notifications::Config do

  it 'should be connect!' do
    subject.reporter = Mock::Reporter
    subject.hostname = "test.host"
    subject.tags = ["custom:tag"]

    client = subject.send(:connect!)
    expect(client).to be_instance_of(Mock::Reporter)
    expect(subject.tags).to eq(["custom:tag", "env:test", "host:test.host"])
  end

  it 'should instantiate plugins on use' do
    subject.use Datadog::Notifications::Plugins::ActionController
    expect(subject.plugins.size).to eq(1)
    expect(subject.plugins.first).to be_instance_of(Datadog::Notifications::Plugins::ActionController)
  end

end
