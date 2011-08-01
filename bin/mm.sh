#!/bin/sh

export VERSION=1.4.2

. `dirname $0`/functions.sh

setup /usr/local/include/mm.h
download ftp://ftp.ossp.org/pkg/lib/mm/mm-$VERSION.tar.gz
rm -rf mm-$VERSION
tar zxf mm-$VERSION.tar.gz
cd mm-$VERSION
./configure --disable-shared
make
make install
cd ..

