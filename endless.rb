#! /usr/bin/ruby

require "net/smtp"

#
# configs
#

PROGRAM = "/root/lightspeed/sv/main.lua"
LOGFILE = "/var/log/lsp-server-endless.log" 
PROGRAMLOGFILE = "/var/log/lsp-server.log"
GDBSCRIPT = "/var/lib/lsp-gdb-script.txt"
PIDFILE = "/var/run/lsp-server.pid"
EMAILFROM = "bot@lsp.io"
EMAILTO = "kengo.nakajima@gmail.com"

#
# subs
#

def output( str )
  f = File.open( LOGFILE, "a+" )
  s = "#{Time.now.to_s} #{str}\n"
  f.print s
  STDERR.print s
  f.close

  
end

def strdate()
  t = Time.now
  return "#{t.year}_#{t.month}_#{t.day}_#{t.hour}_#{t.min}_#{t.sec}"
end


def sendmail(from,to,subj,msg)
  date = `date`.chop

  text  = "Subject: #{subj}\n"
  text += "From: #{from}\n"
  text += "Content-type: text/plain; charset=iso-2022-jp\n"
  text += "Sender: #{from}\n"
  text += "Date: #{date}\n"
  text += "To: #{to}\n"
  text += "\n\n"
  text += "#{msg}\n"
  text += "-----end of message---------------------\n"

  begin
    output "start smtp...\n"
    smtp = Net::SMTP.start( "localhost" , 25 )

    output "send_mail:"
    smtp.send_mail( text, from, to )
    smtp.finish
    output "finished.\n"
    return true
  rescue
    output "SEND ERROR : #{$!}\n"
    output "mail text:\n"
    output text
    return false
  end
end


#
# main
#


f=File.open( PIDFILE, "w")
f.write( Process.pid() )
f.close()

output( "start endless (#{PROGRAM})" )
output( "pwd: #{Dir.pwd}" )


while true 
  output( "starting #{PROGRAM} .." )
  st = Time.now
  system( "#{PROGRAM} > #{PROGRAMLOGFILE} 2>&1" )
  output( "program finished." )
  et = Time.now

  copiedlog = PROGRAMLOGFILE + strdate()
  output( "copying logfile from #{PROGRAMLOGFILE} to #{copiedlog}" )
  system( "cp #{PROGRAMLOGFILE} #{copiedlog}" )
  tail = `tail -200 #{copiedlog}`
  sendmail( EMAILFROM, EMAILTO, "server crash", tail )
  
  dt = et.to_i - st.to_i 
  if dt < 5 then
    output( "server crashed too quick. sleeping.." )
    sleep 5
  end

end



