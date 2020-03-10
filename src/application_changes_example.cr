# ===========================================================
# `ModuleChangeSubscribe`
#
# Testing Module Change Subscription functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Perform module change subscription to sysrepo
# 4a. On module chnage callback, perform a get item and print output
# 4b. Wait until Ctrl+C
# 5. Stop session with sysrepo
# 6. Disconnect from sysrepo
# ===========================================================

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"
require "sysrepo-crystal/subscribe"

LOG_MESSAGE   = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }
MODULE_CHANGE = ->(session : Session, _module_name : String | Nil, _xpath : String | Nil, _event : Libsysrepo::SysrepoEvent, _request_id : UInt32, _private_data : Void*) {
  puts "Perform get item..."
  value = Libsysrepo.sr_get_value
  Libsysrepo.sr_get_item(session.session, "/odin:configData/bah", 5000, pointerof(value))
  Libsysrepo.sr_print_val(value)

  0 # return
}

module ApplicationChangesExample
  VERSION = "0.1.0"

  running = true

  Signal::INT.trap do
    puts "CTRL-C handler here!"
    running = false
  end

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)
  subscribe = Subscribe.new(session)

  data = Pointer(Void).malloc(0)
  subscribe.module_change_subscribe("odin", "", MODULE_CHANGE, data, 0, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect
end
