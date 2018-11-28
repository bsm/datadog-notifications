module Datadog::Notifications::Plugins
  class ActiveJob < Base

    attr_reader :metric_name

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "activejob.perform"
    # *<tt>:tags</tt>        - additional tags
    def initialize(opts={})
      super
      @metric_name = opts[:metric_name] || 'activejob.perform'

      Datadog::Notifications.subscribe 'perform.active_job' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      job  = event.payload[:job]
      name = job.class.name.sub(/Job$/, '').underscore
      tags = self.tags + %W[job:#{name} queue:#{job.queue_name}]

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end

  end
end
