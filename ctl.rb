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
  elsif action == "clean" then
    svctopdir = "#{RELDIR}/#{projname}_#{env}"
    cnt=0
    cleaned = 0
    `ls -t #{svctopdir}/`.split("\n").each do |path|
      if path.size == 40 and path =~ /^([0-9a-f]+)$/ then 
        dirpath = "#{svctopdir}/#{path}"
        elt = elapsedTime(dirpath) 
        toclean = "skip"
        if elapsedTime(dirpath) > CLEAN_THRES and cnt >= 5 then 
          toclean = "clean"
        end
        cnt += 1
        print "#{dirpath} : #{shortdate(elt)}, #{toclean}\n"
        if toclean == "clean" then 
          cmd "rm -rf #{dirpath}"
          cleaned += 1
        end
      end
    end
    p "done. cleaned #{cleaned} dirs."
    exit 0
  end

  # for each services
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

