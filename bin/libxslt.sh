#!/bin/bash

export VERSION=1.1.25

. `dirname $0`/functions.sh

setup /usr/local/include/libxslt/xslt.h
download ftp://xmlsoft.org/libxslt/libxslt-$VERSION.tar.gz
rm -rf libxslt-$VERSION
tar zxf libxslt-$VERSION.tar.gz
cd libxslt-$VERSION
./configure --with-libxml-prefix=/usr/local
make
make install
