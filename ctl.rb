#!/usr/bin/ruby

require "rumino/rumino"
require "common"



def main(argv)
  if argv.size != 2 then 
    eexit "Usage: ctl.rb ENVNAME start|stop|stat"
  end

  env = argv[0]
  action = argv[1]

  conf = readJSON(CONFPATH)
  if !conf then 
    eexit "#{CONFPATH} not found"
  end

  projname = conf["name"]

  outtbl = nil

  if action == "stat" then
    outtbl = []
    outtbl.push(["Process","endless-pid","endless-ps","svc-pid","svc-ps"])
  end

  conf["procs"].each do |procname,procconf|
    name = "#{projname}_#{env}_#{procname}"
    pidpath = "/var/run/#{name}.pid"
    endlesspidpath = "/var/run/#{name}_endless.pid"
    initpath = "/etc/init.d/#{projname}-#{env}-#{procname}"

    
    if action == "stat" then
      line = [ name,"--","--","--","--" ]
      pid = readFile(pidpath)
      if pid then 
        line[3] = pid.to_i
        line[4] = "run" if existProcess(pid.strip.to_i) 
      end
      epid = readFile(endlesspidpath)
      if epid then 
        line[1] = epid.to_i
        line[2] = "run" if existProcess(epid.strip.to_i)
      end
      outtbl.push(line)
    elsif action == "start" then
      p cmd "#{initpath} start"
    elsif action == "stop" then
      p cmd "#{initpath} stop"      
    end
    
  end
  if outtbl then 
    print gentbl(outtbl)
  end
end

#

main(ARGV)

