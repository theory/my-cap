#!/bin/sh

export VERSION=3071502

. `dirname $0`/functions.sh

setup /usr/local/include/sqlite.h
download http://sqlite.org/sqlite-autoconf-$VERSION.tar.gz
build sqlite-autoconf-$VERSION

