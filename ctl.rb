#!/usr/bin/ruby

require "rumino/rumino"
require "common"

INITD = "/etc/init.d"

def main(argv)
  if argv.size != 2 then 
    eexit "Usage: ctl.rb ENVNAME start|stop"
  end
  cmd "#{INITD}/
end

#

main(ARGV)

