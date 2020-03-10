# ===========================================================
# `RPCExample`
#
# Testing RPC Subscription functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Perform RPC subscription to sysrepo
# 4a. On RPC callback, print input values
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
# SessionContext*, LibC::Char*, SysrepoValue*, LibC::UInt32T, SysrepoEvent, LibC::UInt32T, SysrepoValue**, LibC::UInt32T, Void* -> LibC::Int32T
RPC = ->(_session : Session, _op_path : String | Nil, _input : Libsysrepo::SysrepoValue*, _input_cnt : UInt32, _event : Libsysrepo::SysrepoEvent, _request_id : UInt32, _output : Libsysrepo::SysrepoValue**, _output_cnt : UInt32, _private_data : Void*) {
  0 # return
}

module RPCExample
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
  xpath = "/odin:activate-software-image"
  subscribe.sr_rpc_subscribe(xpath, RPC, data, 0, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect
end
