module Datadog::Notifications::Plugins
  class Grape < Base

    def self.exception_status(err)
      err.respond_to?(:status) ? err.status : 500
    end

    attr_reader :metric_name, :exception_handler

    # Options:
    #
    # *<tt>:metric_name</tt> - the metric name, defaults to "grape.request"
    # *<tt>:exception_handler</tt> - a custom exception handler proc which accepts an exception object and returns a status
    # *<tt>:tags</tt> - additional tags
    def initialize(opts={})
      super
      @metric_name = opts[:metric_name] || 'grape.request'
      @exception_handler = opts[:exception_handler] || ->(e) { self.class.exception_status(e) }

      Datadog::Notifications.subscribe 'endpoint_run.grape' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload  = event.payload
      endpoint = payload[:endpoint]
      method   = endpoint.request.request_method

      status = endpoint.status
      status = exception_handler.call(payload[:exception_object]) if payload[:exception_object]

      path = extract_path(endpoint)
      path.gsub!(%r{[^\w\/\-]+}, '_')

      tags = self.tags + %W[method:#{method} status:#{status}]
      tags.push "path:#{path}" if path
      tags.push "version:#{endpoint.version}" if endpoint.version

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end

    def extract_path(endpoint)
      route = begin
                endpoint.route
              rescue NoMethodError
                nil
              end
      return endpoint.request.path unless route

      path = endpoint.route.path.dup
      path.sub!(/\(\.\:format\)$/, '')
      path.sub!(':version/', '') if endpoint.version
      path.gsub!(/:(\w+)/) {|m| m[1..-1].upcase }
      path
    end

  end
end
