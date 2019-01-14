require 'datadog/statsd'
require 'socket'
require 'singleton'
require 'active_support/notifications'
require 'active_support/core_ext/string/inflections'

require 'datadog/notifications/version'
require 'datadog/notifications/reporter'
require 'datadog/notifications/config'
require 'datadog/notifications/plugins'

module Datadog
  class Notifications
    include Singleton

    # Configure and install datadog instrumentation. Example:
    #
    #   Datadog::Notifications.configure do |c|
    #     c.hostname = "my-host"
    #     c.tags     = ["app:mine"]
    #
    #     c.use Datadog::Notifications::Plugins::Grape, metric_name: "api.request", tags: ["grape:specific"]
    #   end
    #
    # Settings:
    # * <tt>hostname</tt>     - the hostname used for instrumentation, defaults to system hostname, respects +INSTRUMENTATION_HOSTNAME+ env variable
    # * <tt>namespace</tt>    - set a namespace to be prepended to every metric name
    # * <tt>tags</tt>         - set an array of tags to be added to every metric
    # * <tt>statsd_host</tt>  - the statsD host, defaults to "localhost", respects +STATSD_HOST+ env variable
    # * <tt>statsd_port</tt>  - the statsD port, defaults to 8125, respects +STATSD_PORT+ env variable
    # * <tt>reporter</tt>     - custom reporter class, defaults to `Datadog::Notifications::Reporter`
    def self.configure(&block)
      if instance.instance_variable_defined?(:@reporter)
        warn "#{name} cannot be reconfigured once it has subscribed to notifications, called from: #{caller(2..2).first}"
        return
      end
      block&.call instance.config
    end

    # You can subscribe to events exactly as with ActiveSupport::Notifications, but there will be an
    # additional `statsd` block parameter available:
    #
    #   Datadog::Notifications.subscribe('render') do |reporter, event|
    #     reporter # => Reporter instance
    #     event    # => ActiveSupport::Notifications::Event object
    #   end
    #
    # Example:
    #
    #   Datadog::Notifications.subscribe('render') do |reporter, _, start, finish, _, payload|
    #     status = payload[:status]
    #     reporter.seconds('myapp.render', finish-start, tags: ["status:#{status}"])
    #   end
    #
    def self.subscribe(pattern, &block)
      instance.subscribe(pattern, &block)
    end

    attr_reader :config

    def initialize
      @config = Config.new
    end

    def subscribe(pattern)
      ActiveSupport::Notifications.subscribe(pattern) do |*args|
        yield reporter, ActiveSupport::Notifications::Event.new(*args)
      end
    end

    private

    def reporter
      @reporter ||= config.send(:connect!)
    end
  end
end
