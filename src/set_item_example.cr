# ===========================================================
# `SetItem`
#
# Testing SetItem functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Perform GetItem
# 4. Perform SetItem
# 5. Perform GetItem
# 6. Stop session with sysrepo
# 7. Disconnect from sysrepo
#
# Also uses crystal stdlib command line OptionParser
# ===========================================================

require "option_parser"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  set_item_value = 0

  OptionParser.parse do |parser|
    parser.banner = "Usage: set_item_example [arguments]"
    parser.on("-v VALUE", "--value=VALUE", "Value to set ( uint8_t )") { |value| set_item_value = value }
    parser.on("-h", "--help", "Show this help") { puts parser }
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection = Connection.new
  session = Session.new(connection)

  puts "Perform set item..."
  puts session.get_item("/odin:configData/bah", 5000)

  puts "Perform set item..."

  value = CrystalSysrepoValue.new
  value.xpath = "/odin:configData/bah"
  value.type = CrystalSysrepoType::SR_UINT8_T
  data = CrystalSysrepoData.new
  data.uint8_val = set_item_value.to_u8
  value.data = data

  session.set_item("/odin:configData/bah", value)

  puts "Perform get item..."
  puts session.get_item("/odin:configData/bah", 5000)

  puts "Perform apply changes..."
  session.apply_changes(0, 0)

  puts "Perform get item..."
  puts session.get_item("/odin:configData/bah", 5000)

  session.session_stop
  connection.disconnect
end
