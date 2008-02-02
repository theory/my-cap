#!/bin/bash

export APACHEVERSION=1.3.39

. `dirname $0`/functions.sh

setup /usr/local/apache/bin/httpd
download http://apache.oregonstate.edu/httpd/apache_$APACHEVERSION.tar.bz2
rm -rf apache_$APACHEVERSION
tar jxf apache_$APACHEVERSION.tar.bz2
cd apache_$APACHEVERSION
./configure \
  --with-layout=Apache \
  --enable-module=so \
  --enable-module=rewrite \
  --enable-module=expires \
  --without-execstrip
make
make install
cd ..
