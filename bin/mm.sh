#!/bin/sh

export MMVERSION=1.4.2

. `dirname $0`/functions.sh

setup /usr/local/src/mm-$MMVERSION
download ftp://ftp.ossp.org/pkg/lib/mm/mm-$MMVERSION.tar.gz
rm -rf mm-$MMVERSION
tar zxf mm-$MMVERSION.tar.gz
cd mm-$MMVERSION
./configure --disable-shared
make
make install
cd ..

