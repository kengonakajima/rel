#! /usr/bin/ruby

require "rumino/rumino"
require "common"

def main(argv)

  if argv.size != 1 then 
    p "Usage: copy.rb ENVNAME"
    exit 1
  end

  env = argv[0]

  topgitdir = "../.git"
  indir = "../sv"
  confpath = "../config.json"

  # check

  if ! exist(topgitdir) then
    eexit "project top .git dir not found"
  end

  conf = readJSON(confpath)
  if !conf then 
    eexit "#{confpath} not found or corrupt"
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
  rm_rf(outdir)
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
  conf["procs"].each do |name,procconf|
    prog = procconf["exec"]
    absprog = "#{projdir}/#{prog}"
    if !exist(absprog) then
      eexit "fatal: executable not found: #{absprog}"
    end
  end

  # link
  cmd "cd #{svctopdir}; mv latest prev; ln -s #{outdir} latest"

  
end


main(ARGV)
