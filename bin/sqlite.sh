#!/bin/sh

export VERSION=3080200
export YEAR=2013

. `dirname $0`/functions.sh

setup /usr/local/include/sqlite.h
download https://sqlite.org/$YEAR/sqlite-autoconf-$VERSION.tar.gz
build sqlite-autoconf-$VERSION

