#!/bin/sh

export VERSION=1.6.0

. `dirname $0`/functions.sh

setup /usr/local/include/uuid.h
download ftp://ftp.ossp.org/pkg/lib/uuid/uuid-$VERSION.tar.gz
rm -rf uuid-$VERSION
tar zxf uuid-$VERSION.tar.gz
cd uuid-$VERSION
./configure --prefix=/usr/local --with-perl=/usr/local/bin/perl
make
make check
make install

cd perl
perl Makefile.PL COMPAT=1
make
make test
make install

cd ../..
