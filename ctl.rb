#!/usr/bin/ruby

require "rumino/rumino"
require "common"

def main(argv)
  if argv.size != 2 then 
    eexit "Usage: ctl.rb ENVNAME start|stop"
  end
  
end

#

main(ARGV)

