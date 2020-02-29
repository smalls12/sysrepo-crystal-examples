# TODO: Write documentation for `GetItem`

require "linked_list"
require "./sysrepo-crystal"
require "./connection"
require "./session"

LOG_MESSAGE = ->( level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char* ) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  list1 = LinkedList(Int32 | String).new

  # TODO: Put your code here
  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  sleep(1)

  puts "Perform get item..."
  value = Libsysrepo.sr_get_value()
  Libsysrepo.sr_get_item(session.session, "/odin:configData/bah", 5000, pointerof(value) )
  Libsysrepo.sr_print_val(value)

  sleep(1)

  session.session_stop
  connection.disconnect

end