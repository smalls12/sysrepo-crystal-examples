# TODO: Write documentation for `ModuleChangeSubscribe`

require "./sysrepo-crystal"
require "./connection"
require "./session"
require "./subscribe"

LOG_MESSAGE = ->( _level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char* ) { puts String.new message }
MODULE_CHANGE = ->( session : Session, _module_name : String | Nil, _xpath : String | Nil,
_event : Libsysrepo::SysrepoEvent, _request_id : UInt32, _private_data : Void* )
{
  puts "Perform get item..."
  value = Libsysrepo.sr_get_value()
  Libsysrepo.sr_get_item(session.session, "/odin:configData/bah", 5000, pointerof(value) )
  Libsysrepo.sr_print_val(value)

  0
}

module ModuleChangeSubscribe
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

  sleep(1)

  data = Pointer(Void).malloc(0)
  subscribe.module_change_subscribe("odin", "", MODULE_CHANGE, data, 0, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  sleep(1)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect

end