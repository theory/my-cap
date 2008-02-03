#!/bin/bash

export VERSION=1.3.26.1a

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/mod_gzip.so
download http://superb-west.dl.sourceforge.net/sourceforge/mod-gzip/mod_gzip-$VERSION.tgz
rm -rf mod_gzip-$VERSION
tar zxf mod_gzip-$VERSION.tgz
cd mod_gzip-$VERSION
patch -p0 < `dirname $0`/../patches/mod_gzip_makefile.patch
make APXS=/usr/local/apache/bin/apxs
make install APXS=/usr/local/apache/bin/apxs
