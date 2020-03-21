# ===========================================================
# `NotifExample`
#
# Testing Event Notification Subscription functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Perform state data subscription to sysrepo
# 4a. On state data callback, populate state data nodes with libyang crystal bindings
# 4b. Wait until Ctrl+C
# 5. Stop session with sysrepo
# 6. Disconnect from sysrepo
# ===========================================================

require "libyang-crystal/context"
require "libyang-crystal/module"
require "libyang-crystal/data-node"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"
require "sysrepo-crystal/subscribe"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }
EVENT_NOTIF = ->(_session : Session, _event_notif_type : Libsysrepo::SysrepoEventNotificationType, _path : String | Nil, values : Array(CrystalSysrepoValue), _timestamp : Libsysrepo::SysrepoTime, _private_data : Void*) {
  values.each{ |value| puts value }
  0 # return
}

module NotifExample
  VERSION = "0.1.0"

  running = true

  Signal::INT.trap do
    puts "CTRL-C handler here!"
    running = false
  end

  # TODO: Put your code here
  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)
  subscribe = Subscribe.new(session)

  data = Pointer(Void).malloc(0)
  module_name = "odin"
  xpath = "/odin:test-notif"
  subscribe.event_notif_subscribe(module_name, xpath, EVENT_NOTIF, data, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect
end
