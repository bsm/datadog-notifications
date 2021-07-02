module Datadog::Notifications::Plugins
  class ActiveJob < Base
    attr_reader :metric_name

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "activejob.perform"
    # *<tt>:tags</tt>        - additional tags
    def initialize(metric_name: 'activejob.perform', **opts)
      super

      @metric_name = metric_name
      Datadog::Notifications.subscribe 'perform.active_job' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      job   = event.payload[:job]
      name  = job.class.name.sub(/Job$/, '').underscore
      queue = job.queue_name.tr(':', '_')
      tags  = self.tags + %W[job:#{name} queue:#{queue}]

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end
  end
end
