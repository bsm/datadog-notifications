module Datadog::Notifications::Plugins
  class Grape < Base

    attr_reader :metric_name

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "grape.request"
    # *<tt>:tags</tt> - additional tags
    def initialize(opts = {})
      super
      @metric_name = opts[:metric_name] || "grape.request"

      Datadog::Notifications.subscribe 'endpoint_run.grape' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload  = event.payload
      endpoint = payload[:endpoint]
      route    = endpoint.route
      version  = route.route_version
      method   = route.route_method

      path = route.route_path.dup
      path.sub!(/\(\.\:format\)$/, '')
      path.sub!(":version/", "") if version
      path.gsub!(/:(\w+)/) {|m| m[1..-1].upcase }
      path.gsub!(/[^\w\/\-]+/, '_')

      tags = self.tags + %W|method:#{method} path:#{path} status:#{endpoint.status}|
      tags.push "version:#{version}" if version

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end

  end
end
