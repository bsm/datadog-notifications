module Datadog::Notifications::Plugins
  class ActionController < Base

    attr_reader :metric_name

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "rails.request"
    # *<tt>:tags</tt> - additional tags
    def initialize(opts={})
      super
      @metric_name = opts[:metric_name] || 'rails.request'

      Datadog::Notifications.subscribe 'process_action.action_controller' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload = event.payload
      method  = payload[:method].downcase
      status  = payload[:status]
      action  = payload[:action]
      ctrl    = payload[:controller].sub(/Controller$/, '').underscore
      format  = payload[:format]
      tags    = self.tags + %W[method:#{method} status:#{status} action:#{action} controller:#{ctrl} format:#{format}]

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
        reporter.timing "#{metric_name}.time.db", payload[:db_runtime], tags: tags
        reporter.timing "#{metric_name}.time.view", payload[:view_runtime], tags: tags
      end
    end

  end
end
