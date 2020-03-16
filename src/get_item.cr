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

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  puts "Perform get item..."
  value = session.get_item("/odin:configData/bah", 5000)
  puts value

  session.session_stop
  connection.disconnect
end
