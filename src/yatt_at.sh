#!/bin/sh
#-*- mode: Shell-script -*-
# programmed by Hiroshi Kimura, 2012-04-30.

ps ax | grep yatt_monitor | grep -v 'grep' >/dev/null

case $? in
1)
	/etc/init.d/yatt-monitor start
	;;
esac

at -f /usr/local/yatt/bin/yatt_at.sh now + 1 minutes
