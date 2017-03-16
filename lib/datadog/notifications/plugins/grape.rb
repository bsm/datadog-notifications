module Datadog::Notifications::Plugins
  class Grape < Base

    attr_reader :metric_name, :exception_handler

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "grape.request"
    # *<tt>:exception_handler</tt> - a custom exception handler proc which accepts an exception object and returns a status
    # *<tt>:tags</tt> - additional tags
    def initialize(opts = {})
      super
      @metric_name = opts[:metric_name] || "grape.request"
      @exception_handler = opts[:exception_handler] || ->_ { 500 }

      Datadog::Notifications.subscribe 'endpoint_run.grape' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload  = event.payload
      endpoint = payload[:endpoint]
      route    = endpoint.route
      version  = route.version
      method   = route.request_method
      status   = endpoint.status

      if payload[:exception_object]
        status = exception_handler.call(payload[:exception_object])
      end

      path = route.pattern.path.dup
      path.sub!(/\(\.\:format\)$/, '')
      path.sub!(":version/", "") if version
      path.gsub!(/:(\w+)/) {|m| m[1..-1].upcase }
      path.gsub!(/[^\w\/\-]+/, '_')

      tags = self.tags + %W|method:#{method} path:#{path} status:#{status}|
      tags.push "version:#{version}" if version

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end

  end
end
