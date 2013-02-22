#!/bin/sh

export VERSION=1.6.2

. `dirname $0`/functions.sh

setup /usr/local/include/ossp/uuid.h
#download ftp://ftp.ossp.org/pkg/lib/uuid/uuid-$VERSION.tar.gz
download http://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/uuid/uuid-$VERSION.tar.gz
rm -rf uuid-$VERSION
tar zxf uuid-$VERSION.tar.gz
cd uuid-$VERSION
# Put the header file in /usr/local/include/ossp-uuid so that, when other apps
# compile, they don't find its uuid_t instead of the system's. This is an
# issue inparticular for Apache.
./configure --prefix=/usr/local --with-perl=/usr/local/bin/perl --includedir=/usr/local/include/ossp 
make -j3
make check
make install

cd perl
# perl Makefile.PL COMPAT=1
# make -j3
# make test
# make install UNINST=1

cd ../..
