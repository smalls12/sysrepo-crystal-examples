# ===========================================================
# `GetItemConcurrent`
#
# Testing GetItem functionality across multiple fibers
#
# 1. Create two connections to sysrepo
# 2. Create a session with sysrepo for each connection
# 3. Perform GetItem on two fibers
# 4. Stop sessions with sysrepo
# 5. Disconnect from sysrepo
# ===========================================================

require "option_parser"

require "sysrepo-crystal/connection"
require "sysrepo-crystal/session"

LOG_MESSAGE = ->(_level : Libsysrepo::SysrepoLoggingLevel, message : LibC::Char*) { puts String.new message }

module GetItemConcurrent
  VERSION = "0.1.0"

  running = true
  channel = Channel(CrystalSysrepoValue).new

  Signal::INT.trap do
    puts "CTRL-C handler here!"
    running = false
    channel.close
  end

  Libsysrepo.sr_log_set_cb(LOG_MESSAGE)

  connection1 = Connection.new
  session1 = Session.new(connection1)

  connection2 = Connection.new
  session2 = Session.new(connection2)

  spawn do
    puts "Fibre1 :: Starting Session1 fiber"
    while running
      puts "Fibre1 :: Before Session1 GetItem"
      begin
        channel.send(session1.get_item("/odin:configData/bah", 0))
      rescue
        puts "Fibre1 :: Rescued!"
      end
      puts "Fibre1 :: After Session1 GetItem"
      sleep 0.5
    end
    puts "Fibre1 :: Closing Session1 fiber"
  end

  spawn do
    puts "Fibre2 :: Starting Session2 fiber"
    while running
      puts "Fibre2 :: Before Session2 GetItem"
      begin
        channel.send(session2.get_item("/odin:configData/okay", 0))
      rescue
        puts "Fibre2 :: Rescued!"
      end
      puts "Fibre2 :: After Session2 GetItem"
      sleep 1
    end
    puts "Fibre2 :: Closing Session2 fiber"
  end

  puts "main :: Wait for CTRL-C ..."
  while running
    puts "main :: Before receive"
    begin
      puts channel.receive
    rescue
      puts "main :: Rescued!"
    end
    puts "main :: After receive"
    sleep 0.01
  end

  puts "main :: Wait for Fibers to finish"
  Fiber.yield

  session2.session_stop
  connection2.disconnect

  session1.session_stop
  connection1.disconnect
end
