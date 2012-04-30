#!/bin/sh
# programmed by Hiroshi Kimura, 2012-04-30.

ps ax | grep yatt_monitor | grep -v 'grep' >/dev/null && exit
/etc/init.d/yatt-monitor start
