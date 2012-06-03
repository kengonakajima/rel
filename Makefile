stat:
	ruby ctl.rb dev stat

dev:
	ruby copy.rb dev


restart:
	ruby ctl.rb dev stop
	ruby ctl.rb dev start
