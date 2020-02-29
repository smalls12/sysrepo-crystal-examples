# TODO: Write documentation for `TestApp`

require "./sysrepo-crystal"
require "./connection"
require "./session"

LOG_MESSAGE = ->(level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module TestApp
  VERSION = "0.1.0"

  # TODO: Put your code here
  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  sleep(1);

  puts "Perform get item..."
  value = Libsysrepo.sr_get_value()
  Libsysrepo.sr_get_item(session.session, "/ietf-datastores:*", 5000, pointerof(value) )

  sleep(1);

end