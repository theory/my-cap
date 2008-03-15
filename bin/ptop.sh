#!/bin/bash

export VERSION=3.6.2-beta1

. `dirname $0`/functions.sh

setup /usr/local/include/expat.h
download http://pgfoundry.org/frs/download.php/1694/ptop-$VERSION.tar.bz2
if [ $OS = 'Darwin' ]; then
    cd ptop-$VERSION
    ./configure --with-module=macosx
    make
    make install
    cd ..
else
    build ptop-$VERSION
fi
