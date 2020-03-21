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

require "./option_parser"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  get_item_xpath = "/odin:configData/bah"

  OptionParser.parse do |parser|
    parser.banner = "Usage: set_item_example [arguments]"
    parser.on("-x VALUE", "--xpath=VALUE", "xpath of item to retrieve") { |value| get_item_xpath = value }
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

  puts "Perform get item..."
  value = session.get_item(get_item_xpath, 0)
  puts value

  session.session_stop
  connection.disconnect
end
