stat:
	ruby ctl.rb dev stat
	ruby ctl.rb prod stat

dev:
	ruby copy.rb dev

prod:
	ruby copy.rb prod

start_dev:
	ruby ctl.rb dev start

stop_dev:
	ruby ctl.rb dev stop

start_prod:
	ruby ctl.rb prod start

stop_prod:
	ruby ctl.rb prod stop

clean_dev:
	ruby ctl.rb dev clean

tail_prod:
	ruby ctl.rb prod tail

tail_dev:
	ruby ctl.rb dev tail
