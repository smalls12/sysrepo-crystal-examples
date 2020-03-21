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
#
# Also uses crystal stdlib command line OptionParser
# ===========================================================

require "./option_parser"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItem
  VERSION = "0.1.0"

  get_items_xpath = "/odin:configData/bah"

  OptionParser.parse do |parser|
    parser.banner = "Usage: set_item_example [arguments]"
    parser.on("-x VALUE", "--xpath=VALUE", "xpath of item to retrieve") { |value| get_items_xpath = value }
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

  str = String.build do |io|
    io << "Perform get items on [ "
    io << get_items_xpath
    io << " ]"
  end
  puts str

  array = session.get_items(get_items_xpath, 0)
  array.each{ |value| puts value }

  session.session_stop
  connection.disconnect
end
