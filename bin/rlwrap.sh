#!/bin/bash

export VERSION=0.37

. `dirname $0`/functions.sh

setup /usr/local/bin/rlwrap
download http://utopia.knoware.nl/~hlub/uck/rlwrap/rlwrap-$VERSION.tar.gz
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
build rlwrap-$VERSION
