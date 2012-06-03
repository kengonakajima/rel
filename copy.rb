#! /usr/bin/ruby

require "rumino/rumino"
require "common"
require "erb"

def main(argv)

  if argv.size != 1 then 
    p "Usage: copy.rb ENVNAME"
    exit 1
  end

  env = argv[0]


  # check
  if ! exist(TOPGITDIR) then
    eexit "project top .git dir not found"
  end

  conf = readJSON(CONFPATH)
  if !conf then 
    eexit "#{CONFPATH} not found or corrupt"
  end


  gst = `cd ..; git status`
  lastline = gst.split("\n")[-1]
  if lastline != "nothing to commit (working directory clean)" then 
#    eexit "working directory has mods!\n#{quote(gst)}"
    p "DEBUG: working directory has mods!\n#{quote(gst)}"
  end

  sha = `cd ..; git log`.split("\n")[0].split(" ")[1].strip
  if sha.size != 40 then 
    eexit "couldn't get SHA"
  end
  
  # copy
  projname = conf["name"]
  p "project name: #{projname}"

  mkdir(RELDIR) 

  svctopdir = "#{RELDIR}/#{projname}_#{env}"
  mkdir(svctopdir) 

  outdir = "#{svctopdir}/#{sha}"
  cmd "rm -rf #{outdir}"
  if ! mkdir(outdir) then 
    eexit "fatal: mkdir failed: #{outdir}"
  end
  
  projdir = "#{outdir}/#{projname}"

  cmd "cp -r .. #{projdir}"
  
  # clean
  conf["skip"].each do |pat|
    rm_rf("#{projdir}/#{pat}")
  end
  cmd "find #{projdir} -name '.git*' -exec rm -rf {} \\; 2>&1"

  # verify
  conf["procs"].each do |procname,procconf|
    p "configure process #{procname}.."
    prog = procconf["exec"]
    absprog = "#{projdir}/#{prog}"
    if !exist(absprog) then
      eexit "fatal: executable not found: #{absprog}"
    end
    
    # init.d 
    relwd = conf["workdir"]
    args = "#{env}.json"
    endlesspath = "#{svctopdir}/latest/#{projname}/#{relwd}/endless_#{procname}.rb"
    execpath = endlesspath
    name = "#{projname}_#{env}_#{procname}"
    pidpath = "/var/run/#{name}.pid"
    endlesspidpath = "/var/run/#{name}_endless.pid"    
    execdir = "#{svctopdir}/latest/#{projname}/#{relwd}"
    scr = doerb("init.d.tmpl",binding)
    scrname = "#{projname}-#{env}-#{procname}"
    scroutpath = "/etc/init.d/#{scrname}"
    if writeFile( scroutpath, scr ) then 
      p "wrote #{scroutpath}"
    end      
    cmd( "chmod 755 #{scroutpath}" )
    cmd( "ln -s #{projdir}/rel/rumino #{projdir}/sv/rumino" ) 
    cmd( "update-rc.d #{scrname} start 30 2 3 4 5 ." )

    # endless
    programpath = absprog
    logpath = "/var/log/#{name}_endless.log"
    programlogpath = "/var/log/#{name}.log"
    emailfrom = "#{name}_bot@ringo.io"
    emailto = "kengo.nakajima@gmail.com"
    scr = doerb( "endless.rb.tmpl",binding)
    if writeFile( endlesspath, scr ) then
      p "wrote #{endlesspath}"
    end
    cmd( "chmod 755 #{endlesspath}" )

    # config json
    jsonpath = "#{execdir}/#{env}.json"
    h = { "pidFile" => pidpath }
    if writeFile(jsonpath,h.to_json) then 
      p "wrote #{jsonpath}"
    end

  end

  # link
  cmd "cd #{svctopdir}; mv latest prev; ln -s #{outdir} latest"
  
end


main(ARGV)
