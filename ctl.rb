#!/usr/bin/ruby

require "rumino/rumino"
require "common"



def main(argv)
  if argv.size != 2 then 
    eexit "Usage: ctl.rb ENVNAME start|stop|stat|test|tail"
  end

  env = argv[0]
  action = argv[1]

  conf = readJSON(CONFPATH)
  if !conf then 
    eexit "#{CONFPATH} not found"
  end

  projname = conf["name"]

  outtbl = nil

  svctopdir = "#{RELDIR}/#{projname}_#{env}"

  if action == "stat" then
    outtbl = []
    outtbl.push(["Process","endless-pid","endless-ps","svc-pid","svc-ps"])
  elsif action == "tail" then
    system( "tail -n 100 -f /var/log/#{projname}_#{env}_*" )
  elsif action == "clean" then
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

    wd = conf["workdir"] 
    procjson = "#{svctopdir}/latest/#{projname}/#{wd}/#{env}.json"
    
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
      sleep 2
    elsif action == "stop" then
      p cmd "#{initpath} stop" 
      sleep 2
    elsif action == "test" then 
      p env
      cf = readJSON(procjson)
      p "test:", procname, cf["test"]
      if cf["test"] then
        cmdline = cf["test"]["command"]
        expect = cf["test"]["expect"]
        res = cmd(cmdline)
        if expect.strip == res.strip then 
          p "test OK"
        else
          p "test failed. expect:'#{expect}' result:'#{res}'"
        end
      else
        p "'test' config is not found in #{procjson}"
      end
    end
    
  end
  if outtbl then 
    print gentbl(outtbl)
  end
end

#

main(ARGV)

