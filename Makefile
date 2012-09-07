stat_all: stat_prod stat_dev

stat_prod:
	ruby ctl.rb prod stat

stat_dev:
	ruby ctl.rb dev stat

install_dev:
	ruby copy.rb dev

install_prod:
	ruby copy.rb prod

start_dev:
	ruby ctl.rb dev start

stop_dev:
	ruby ctl.rb dev stop

start_prod:
	ruby ctl.rb prod start

stop_prod:
	ruby ctl.rb prod stop
	sleep 0.5
	ruby ctl.rb prod stat

clean_dev:
	ruby ctl.rb dev clean

tail_prod:
	ruby ctl.rb prod tail

tail_dev:
	ruby ctl.rb dev tail

test_prod:
	ruby ctl.rb prod test

test_dev:
	ruby ctl.rb dev test
