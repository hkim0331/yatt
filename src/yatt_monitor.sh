#!/bin/sh
#-*- mode: Shell-script -*-
# programmed by Hiroshi Kimura, 2012-04-30.

ps ax | grep yatt_monitor.rb | grep -v 'grep' >/dev/null

case $? in
1)
	/usr/local/yatt/bin/yatt_monitor.rb --hostname edu.melt.kyutech.ac.jp \
	    --log /dev/null
	;;
esac

at -f /usr/local/yatt/bin/yatt_monitor.sh now + 1 minutes
