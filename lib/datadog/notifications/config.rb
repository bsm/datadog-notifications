module Datadog
  class Notifications
    class Config
      attr_accessor :hostname, :namespace, :tags, :statsd_host, :statsd_port, :reporter, :plugins, :socket_path

      def initialize
        @hostname    = ENV.fetch('INSTRUMENTATION_HOSTNAME') { Socket.gethostname }
        @statsd_host = ENV.fetch('STATSD_HOST', nil)
        @statsd_port = ENV.fetch('STATSD_PORT', nil)
        @socket_path = ENV.fetch('SOCKET_PATH', nil)
        @reporter    = Datadog::Notifications::Reporter
        @tags        = []
        @plugins     = []
      end

      # Use a plugin
      def use(klass, **opts)
        @plugins.push klass.new(**opts)
      end

      protected

      def connect!
        env = ENV.fetch('RAILS_ENV') { ENV.fetch('RACK_ENV', nil) }
        tags.push("env:#{env}")       if env && tags.none? {|t| t =~ /^env:/ }

        enable_hostname = hostname && hostname != 'false'
        tags.push("host:#{hostname}") if enable_hostname && tags.none? {|t| t =~ /^host:/ }

        reporter.new statsd_host, statsd_port, namespace: namespace, tags: tags, socket_path: socket_path
      end
    end
  end
end
