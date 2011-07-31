#!/bin/bash

export VERSION=1.5.4

. `dirname $0`/functions.sh

setup /usr/local/include/png.h
download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-$VERSION.tar.gz
rm -rf libpng-$VERSION
tar zxf libpng-$VERSION.tar.gz
cd libpng-$VERSION
cp scripts/makefile.darwin makefile
perl -i -pe 's/PNGVER\s*=\s*\$\(PNGMAJ\)\./PNGVER = /' makefile
make
make install
