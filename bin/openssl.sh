#!/bin/bash

export VERSION=1.1.0h

. `dirname $0`/functions.sh

setup
download https://www.openssl.org/source/openssl-$VERSION.tar.gz
tar zxf openssl-$VERSION.tar.gz
cd openssl-$VERSION
./Configure darwin64-x86_64-cc
make
#make test
make install
