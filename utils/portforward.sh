#!/bin/sh
#2017-09-30 これでポートフォワードは成功した実績はあるのか？
ssh -f -N -L 23002:127.0.0.1:23002 -R 23003:127.0.0.1:23003 dbs.melt.kyutech.ac.jp

