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

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  path = "/odin:activate-software-image"

  crystal_input_values = Array(CrystalSysrepoValue).new

  crystal_value = CrystalSysrepoValue.new
  crystal_value.xpath = "/odin:activate-software-image/image-name"
  crystal_value.type = CrystalSysrepoType::SR_STRING_T
  data = CrystalSysrepoData.new
  data.string_val = "whoa"
  crystal_value.data = data

  crystal_input_values.push(crystal_value)

  crystal_value = CrystalSysrepoValue.new
  crystal_value.xpath = "/odin:activate-software-image/location"
  crystal_value.type = CrystalSysrepoType::SR_STRING_T
  data = CrystalSysrepoData.new
  data.string_val = "here"
  crystal_value.data = data

  crystal_input_values.push(crystal_value)

  crystal_output_values = Array(CrystalSysrepoValue).new

  session.rpc_send(path, crystal_input_values, crystal_output_values)

  crystal_output_values.each{ |value| puts value }

  session.session_stop
  connection.disconnect
end
