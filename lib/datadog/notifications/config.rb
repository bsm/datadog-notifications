module Datadog
  class Notifications
    class Config
      attr_accessor :hostname, :namespace, :tags, :statsd_host, :statsd_port, :reporter, :plugins

      def initialize
        @hostname    = ENV['INSTRUMENTATION_HOSTNAME'] || Socket.gethostname
        @statsd_host = ENV['STATSD_HOST'] || ::Datadog::Statsd::DEFAULT_HOST
        @statsd_port = (ENV['STATSD_PORT'] || ::Datadog::Statsd::DEFAULT_PORT).to_i
        @reporter    = Datadog::Notifications::Reporter
        @tags        = []
        @plugins     = []
      end

      # Use a plugin
      def use(klass, opts = {})
        @plugins.push klass.new(opts)
      end

      def connect!
        env = ENV['RAILS_ENV'] || ENV['RACK_ENV']
        tags.push("env:#{env}")       if env && tags.none? {|t| t =~ /^env\:/ }
        tags.push("host:#{hostname}") if tags.none? {|t| t =~ /^host\:/ }

        reporter.new statsd_host, statsd_port, namespace: namespace, tags: tags
      end
      protected :connect!

    end
  end
end
