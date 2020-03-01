# TODO: Write documentation for `OperDataExample`
require "libyang-crystal/context"
require "libyang-crystal/module"
require "libyang-crystal/data-node"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"
require "sysrepo-crystal/subscribe"

LOG_MESSAGE = ->( level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char* ) { puts String.new message }
OPER_DATA = ->( session : Session, module_name : String | Nil, xpath : String | Nil,
request_xpath : String | Nil, request_id : UInt32, parent : DataNode*, private_data : Void* )
{
  puts " === OPER_DATA_EXTERNAL === "

  ctx = Context.new(session.get_context())
  # had to use not nil here
  mod = ctx.get_module(module_name.not_nil!)

  parent = DataNode.new(ctx, "/odin:stateData", nil, Libyang::LYDANYDATAVALUETYPE::LYD_ANYDATA_CONSTSTRING, 0)
  # stateData = DataNode.new(parent, mod, "stateData")
  blah = DataNode.new(parent, mod, "blah", "4")

  puts " === OPER_DATA_EXTERNAL === "

  return 0
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

  sleep(1)

  data = Pointer(Void).malloc(0)
  module_name = "odin"
  xpath = "/odin:stateData"
  subscribe.oper_data_subscribe(module_name, xpath, OPER_DATA, data, Libsysrepo::SysrepoSubscriptionOptions::DEFAULT)

  sleep(1)

  puts "Wait for CTRL-C ..."
  while running
    sleep 0.01
  end

  subscribe.unsubscribe
  session.session_stop
  connection.disconnect

end