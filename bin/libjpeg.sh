#!/bin/bash

export VERSION=6b

. `dirname $0`/functions.sh

setup /usr/local/include/jpeglib.h
download http://www.ijg.org/files/jpegsrc.v$VERSION.tar.gz
build jpegsrc.v$VERSION jpeg-$VERSION
make install-lib
ranlib /usr/local/lib/libjpeg.a
