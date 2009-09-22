#!/bin/bash

export VERSION=1.33

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/libfoo.so
download http://apache.oregonstate.edu/httpd/libapreq/libapreq-$VERSION.tar.gz
rm -rf libapreq-$VERSION
tar zxf libapreq-$VERSION.tar.gz || exit $?
cd libapreq-$VERSION || exit $?
./configure --with-apache-includes=/usr/local/apache/include || exit $?
make || exit $?
sudo make install || exit $?

/usr/local/bin/perl Makefile.PL || exit $?
make -j3 || exit $?
make test || exit $?
make install UNINST=1 || exit $?
cd ..