#!/bin/sh
# -*- mode: Shell-script; coding: utf-8; -*-

if [ ! $# = 1 ]; then
    echo usage: $0 VERSION
    exit
fi
VERSION=$1

# in Linux, sed = gnu sed, in OSX, sed != gnu sed.
if [ -e /usr/local/bin/gsed ]; then
    SED=/usr/local/bin/gsed
else
    SED=`which sed`
fi

# files to footprint version number.
FILES="db/Makefile src/Makefile src/*.rb"

# normally, format of comments are '# VERSION: number'.
for i in ${FILES}; do
    ${SED} -i.bak "s/^# VERSION:.*$/# VERSION: ${VERSION}/" $i
done

TODAY=`date +%F`
for i in src/yatt.rb src/yatt_monitor.rb; do
    if [[ $i =~ bak$ ]]; then
        continue;
    fi
    ${SED} -i.bak \
           -e "s/^YATT_VERSION\s*=.*$/YATT_VERSION = '${VERSION}'/" \
           -e "s/^DATE\s*=.*$/DATE = '${TODAY}'/" $i
done

echo ${VERSION} > VERSION
