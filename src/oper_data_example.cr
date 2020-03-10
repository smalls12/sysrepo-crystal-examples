# ===========================================================
# `OperDataExample`
#
# Testing State Data Subscription functionality
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
OPER_DATA   = ->(session : Session, module_name : String | Nil, _xpath : String | Nil, _request_xpath : String | Nil, _request_id : UInt32, parent : DataNode, _private_data : Void*) {
  ctx = Context.new(session.get_context)
  # had to use not nil here
  mod = ctx.get_module(module_name.not_nil!)

  parent.reset(ctx, "/odin:stateData", nil, Libyang::LYDANYDATAVALUETYPE::LYD_ANYDATA_CONSTSTRING, 0)
  DataNode.new(parent, mod, "blah", "4")

  0 # return
}

module OperDataExample
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
  xpath = "/odin:stateData"
  subscribe.oper_data_subscribe(module_name, xpath, OPER_DATA, data, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect
end
