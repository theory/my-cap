#!/bin/bash

export VERSION=2.0.1
export GITHASH=f4b2b1a

. `dirname $0`/functions.sh

setup
download https://github.com/lloyd/yajl/tarball/$VERSION
tar zxf $VERSION
cd lloyd-yajl-$GITHASH
./configure
make
make install
