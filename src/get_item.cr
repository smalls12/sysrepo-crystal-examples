# ===========================================================
# `GetItem`
#
# Testing GetItem functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Perform GetItem
# 4. Stop session with sysrepo
# 5. Disconnect from sysrepo
# ===========================================================

require "linked_list"
require "./sysrepo-crystal"
require "./connection"
require "./session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  list1 = LinkedList(Int32 | String).new

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  puts "Perform get item..."
  value = Libsysrepo.sr_get_value
  Libsysrepo.sr_get_item(session.session, "/odin:configData/bah", 5000, pointerof(value))
  Libsysrepo.sr_print_val(value)

  session.session_stop
  connection.disconnect
end
