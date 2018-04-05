module Datadog
  class Notifications
    module Plugins
    end
  end
end

%w[base grape active_record active_job action_controller].each do |name|
  require "datadog/notifications/plugins/#{name}"
end
