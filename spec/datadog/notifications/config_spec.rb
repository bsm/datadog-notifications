require 'spec_helper'

describe Datadog::Notifications::Config do
  it 'is connect!' do
    subject.hostname = 'test.host'
    subject.tags = ['custom:tag']

    client = subject.send(:connect!)
    expect(client).to be_instance_of(Datadog::Notifications::Reporter)
    expect(subject.tags).to eq(['custom:tag', 'env:test', 'host:test.host'])
  end

  RSpec.shared_examples 'host tag is not picked up' do |hostname|
    it 'does not pick up the host tag' do
      subject.hostname = hostname
      subject.tags = ['custom:tag']

      client = subject.send(:connect!)
      expect(client).to be_instance_of(Datadog::Notifications::Reporter)
      expect(subject.tags).to eq(['custom:tag', 'env:test'])
    end
  end

  include_examples 'host tag is not picked up', false
  include_examples 'host tag is not picked up', 'false'

  it 'instantiates plugins on use' do
    subject.use Datadog::Notifications::Plugins::ActionController
    expect(subject.plugins.size).to eq(1)
    expect(subject.plugins.first).to be_instance_of(Datadog::Notifications::Plugins::ActionController)
  end
end
