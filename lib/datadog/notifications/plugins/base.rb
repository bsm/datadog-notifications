module Datadog::Notifications::Plugins
  class Base
    attr_reader :tags

    # Options:
    #
    # *<tt>:tags</tt> - additional tags
    def initialize(opts={})
      @tags = opts[:tags] || []
    end

  end
end
