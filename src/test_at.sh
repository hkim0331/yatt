#!/bin/sh
date "+%H:%M:%S" >/dev/pts/0
at -f /home/hkim/at/test_at.sh now + 1 minutes
