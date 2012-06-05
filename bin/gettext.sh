#!/bin/bash

export VERSION=0.18.1.1

. `dirname $0`/functions.sh

if [ "`/usr/local/bin/gettext --version | head -1 | awk '{print $4}'`" = $VERSION ]; then
    exit 0
fi
setup
download ftp://ftp.gnu.org/gnu/gettext/gettext-$VERSION.tar.gz
# XXX Ugh, have to patch it, so have to build it manually ourselves.
#build gettext-$VERSION
tar zxf gettext-$VERSION.tar.gz
cd gettext-$VERSION
curl 'https://trac.macports.org/export/79617/trunk/dports/devel/gettext/files/stpncpy.patch' | patch -p0
./configure
make
make install

