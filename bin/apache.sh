#!/bin/bash

export VERSION=1.3.39

. `dirname $0`/functions.sh

setup /usr/local/apache/bin/httpd
download http://apache.oregonstate.edu/httpd/apache_$VERSION.tar.bz2
rm -rf apache_$VERSION
tar jxf apache_$VERSION.tar.bz2
cd apache_$VERSION
./configure \
  --with-layout=Apache \
  --enable-module=so \
  --enable-module=rewrite \
  --enable-module=expires \
  --without-execstrip
make
make install
cd ..
