#!/bin/bash

export VERSION=1.19.1

. `dirname $0`/functions.sh

setup /usr/local/bin/wget
download http://ftp.gnu.org/gnu/wget/wget-$VERSION.tar.gz
rm -rf wget-$VERSION
tar zxf wget-$VERSION.tar.gz
cd wget-$VERSION
./configure --prefix=/usr/local --with-ssl=openssl
make
make install

#make check
