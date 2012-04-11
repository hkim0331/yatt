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
# 2021-01-28, add comments.


if [ ! $# = 1 ]; then
	echo usage: $0 VERSION
	exit
fi
VERSION=$1

# files to footprint version number.
FILES="src/*"

# normally, format of comments are '# VERSION: number'.
for i in ${FILES}; do
    sed -i.bak "s/^# VERSION:.*$/# VERSION: ${VERSION}/" $i
done

# special format example.
#sed -i.bak "s/PBL2011_VERSION=.*$/PBL2011_VERSION=${VERSION}/" \
#	common.rb
DATE=`date +"%Y-%m-%d"`
for i in src/yatt.rb src/yatt_server.rb; do
    sed -i.bak \
	-e "s/^YATT_VERSION\s*=.*$/YATT_VERSION='${VERSION}'/" \
	-e "s/^DATE\s*=.*$/DATE='${DATE}'/" $i
done
	
