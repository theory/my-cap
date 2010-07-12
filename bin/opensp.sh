#!/bin/bash

export VERSION=1.5.2

. `dirname $0`/functions.sh

setup
download http://softlayer.dl.sourceforge.net/sourceforge/openjade/OpenSP-$VERSION.tar.gz
tar zxf OpenSP-$VERSION.tar.gz
cd OpenSP-$VERSION
./configure --disable-doc-build
make
make install
