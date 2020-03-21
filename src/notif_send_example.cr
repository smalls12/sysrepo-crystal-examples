# ===========================================================
# `NotifSendExample`
#
# Testing NotifSendExample functionality
#
# 1. Create connection to sysrepo
# 2. Create session with sysrepo
# 3. Send notification
# 4. Stop session with sysrepo
# 5. Disconnect from sysrepo
# ===========================================================

require "./option_parser"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module NotifSendExample
  VERSION = "0.1.0"

  event_notification_xpath = "/odin:test-notif"

  OptionParser.parse do |parser|
    parser.banner = "Usage: set_item_example [arguments]"
    parser.on("-x VALUE", "--xpath=VALUE", "xpath of notification to send") { |value| event_notification_xpath = value }
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

  puts "Perform send event notification..."
  crystal_values = Array(CrystalSysrepoValue).new

  crystal_value = CrystalSysrepoValue.new
  crystal_value.xpath = "/odin:test-notif/val1"
  crystal_value.type = CrystalSysrepoType::SR_STRING_T
  data = CrystalSysrepoData.new
  data.string_val = "ok"
  crystal_value.data = data

  crystal_values.push(crystal_value)

  crystal_value = CrystalSysrepoValue.new
  crystal_value.xpath = "/odin:test-notif/val2"
  crystal_value.type = CrystalSysrepoType::SR_STRING_T
  data = CrystalSysrepoData.new
  data.string_val = "sweet"
  crystal_value.data = data

  crystal_values.push(crystal_value)

  session.event_notif_send(event_notification_xpath, crystal_values)

  session.session_stop
  connection.disconnect
end
