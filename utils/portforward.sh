#!/bin/sh

ssh -f -N -L 23002:localhost:23002 -R 23003:localhost:23003 dbs.melt.kyutech.ac.jp

