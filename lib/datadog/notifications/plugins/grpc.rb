module Datadog::Notifications::Plugins
  class GRPC < Base

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to 'grpc.request'
    # *<tt>:tags</tt> - additional tags
    #
    # It expects ActiveSupport instrumented notifications named 'process_action.grpc'.
    # Notification payload should have :service (service name, string) and :action (service action/method name, string) keys.
    #
    # Compatible instrumentation is implemented in grpcx gem: https://github.com/bsm/grpcx (>= 0.2.0)
    def initialize(opts={})
      super
      @metric_name = opts[:metric_name] || 'grpc.request'

      Datadog::Notifications.subscribe 'process_action.grpc' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload = event.payload
      service = payload[:service]
      action  = payload[:action]
      status  = payload[:exception] ? 'error' : 'ok'

      tags = self.tags + %W[service:#{service} action:#{action} status:#{status}]

      reporter.batch do
        reporter.increment @metric_name, tags: tags
        reporter.timing "#{@metric_name}.time", event.duration, tags: tags
      end
    end

  end
end
