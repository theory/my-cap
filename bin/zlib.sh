#!/bin/bash

export VERSION=1.2.8

. `dirname $0`/functions.sh

setup /usr/local/include/zlib.h "ZLIB_VERSION \"$VERSION\""
download http://www.zlib.net/zlib-$VERSION.tar.gz
build zlib-$VERSION
