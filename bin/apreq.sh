#!/bin/bash

export VERSION=1.33

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/libfoo.so
download http://apache.oregonstate.edu/httpd/libapreq/libapreq-$VERSION.tar.gz
rm -rf libapreq-$VERSION
tar zxf libapreq-$VERSION.tar.gz
cd libapreq-$VERSION
./configure --with-apache-includes=/usr/local/apache/include
make
sudo make install

perl Makefile.PL
make
make test
make install UNINST=1
cd ..