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
  
  if ! exist(topgitdir) then
    eexit "project top .git dir not found"
  end

  if ! exist(confpath) then 
    eexit "config.json not found in this project"
  end

  gst = `cd ..; git status`
  lastline = gst.split("\n")[-1]
  if lastline != "nothing to commit (working directory clean)" then 
    eexit "working directory has mods!\n#{quote(gst)}"
  end

  
end


main(ARGV)
