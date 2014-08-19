#!/bin/bash

export VERSION=2.9.1

. `dirname $0`/functions.sh

setup /usr/local/include/libxml2/libxml/parser.h "echo $VERSION"
download ftp://xmlsoft.org/libxml2/libxml2-$VERSION.tar.gz
#build libxml2-$VERSION

# Cut from here down.
tar zxf libxml2-$VERSION.tar.gz
cd libxml2-$VERSION
./configure
make
make install

