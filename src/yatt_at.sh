#!/bin/sh
# programmed by Hiroshi Kimura, 2012-04-30.

ps ax | grep yatt_monitor | grep -v 'grep' >/dev/null && exit
/etc/init.d/yatt-monitor start
at -f /usr/local/yatt/bin/yatt_at.sh now + 1 minutes
