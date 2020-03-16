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

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module RPCSendExample
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

  path = "/odin:activate-software-image"

  session.rpc_send(path, nil, 0)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  session.session_stop
  connection.disconnect
end
