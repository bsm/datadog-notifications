module Datadog
  class Notifications
    module Plugins
      autoload :Base,             'datadog/notifications/plugins/base'
      autoload :Grape,            'datadog/notifications/plugins/grape'
      autoload :ActiveRecord,     'datadog/notifications/plugins/active_record'
      autoload :ActiveJob,        'datadog/notifications/plugins/active_job'
      autoload :ActionController, 'datadog/notifications/plugins/action_controller'
      autoload :GRPC,             'datadog/notifications/plugins/grpc'
    end
  end
end
