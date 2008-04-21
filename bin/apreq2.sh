#!/bin/bash

export VERSION=2.08

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/libfoo.so
download http://apache.oregonstate.edu/httpd/libapreq/libapreq2-$VERSION.tar.gz
rm -rf libapreq2-$VERSION
tar zxf libapreq2-$VERSION.tar.gz || exit $?
cd libapreq2-$VERSION
./configure --with-apache2-apxs=/usr/local/apache2/bin/apxs || exit $?
make || exit $?
sudo make install || exit $?

/usr/local/bin/perl Makefile.PL --with-apache2-apxs=/usr/local/apache2/bin/apxs || exit $?
make || exit $?
make test || exit $?
make install UNINST=1 || exit $?
cd ..