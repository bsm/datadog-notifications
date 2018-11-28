module Datadog::Notifications::Plugins
  class ActiveRecord < Base

    attr_reader :metric_name

    # Options:
    #
    # *<tt>:metric_name</tt>      - the metric name, defaults to "activerecord.query"
    # *<tt>:include_schema</tt>   - record schema queries, off by default
    # *<tt>:include_generic</tt>  - record general (nameless) queries, off by default
    # *<tt>:tags</tt>             - additional tags
    def initialize(opts={})
      super
      @metric_name     = opts[:metric_name] || 'activerecord.sql'
      @include_schema  = opts[:include_schema] == true
      @include_generic = opts[:include_generic] == true
      @include_raw     = opts[:include_raw] == true

      Datadog::Notifications.subscribe 'sql.active_record' do |reporter, event|
        record reporter, event
      end
    end

    private

    def record(reporter, event)
      payload = event.payload
      name    = payload[:name]
      return if (name.nil? || name == 'SQL') && !@include_generic
      return if name == 'SCHEMA' && !@include_schema

      name = name.downcase.split(/\W/).join('.') if name
      tags = self.tags.dup
      tags.push "query:#{name}" if name

      reporter.batch do
        reporter.increment metric_name, tags: tags
        reporter.timing "#{metric_name}.time", event.duration, tags: tags
      end
    end

  end
end
