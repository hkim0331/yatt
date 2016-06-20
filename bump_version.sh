#!/usr/bin/env dash
# -*- mode: Shell-script; coding: utf-8; -*-
#
# programmed by Hiroshi Kimura, 2012-01-12.
#
# = bump_version_model.sh
# プロジェクト内のファイルに一貫するバージョンナンバーを付与する。
#
# == usage
# 1. このファイルをプロジェクトフォルダにコピーし、
# 2. FILESに必要なファイルをスペースで区切ってリスト
# 3. do it.
#
# == updats
# 2012-01-15, updated.
# 2012-01-28, add comments.
# 2015-04-23, stop backup *.bak files. (under constrution)

if [ ! $# = 1 ]; then
    echo usage: $0 VERSION
    exit
fi
VERSION=$1

# in Linux, sed = gnu sed, in OSX, sed != gnu sed.
if [ `uname` = 'Linux' ]; then
    SED=/bin/sed
else
    SED=/usr/local/bin/gsed
fi

# files to footprint version number.
FILES="db/Makefile src/Makefile"

# normally, format of comments are '# VERSION: number'.
for i in ${FILES}; do
    ${SED} -i.bak "s/^# VERSION:.*$/# VERSION: ${VERSION}/" $i
done

DATE=`date +%Y-%m-%d`
# FIXME: must skip *.bak files.
for i in src/*; do
    ${SED} -i.bak \
           -e "s/^YATT_VERSION\s*=.*$/YATT_VERSION = '${VERSION}'/" \
           -e "s/^DATE\s*=.*$/DATE = '${DATE}'/" $i
done

echo ${VERSION} > VERSION

