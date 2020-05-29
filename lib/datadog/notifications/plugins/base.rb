module Datadog::Notifications::Plugins
  class Base
    attr_reader :tags

    # Options:
    #
    # *<tt>:tags</tt> - additional tags
    def initialize(tags: [], **_opts)
      @tags = tags
    end
  end
end
