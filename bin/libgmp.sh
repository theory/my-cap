#!/bin/bash

export VERSION=5.0.2

. `dirname $0`/functions.sh

setup /usr/local/include/gmp.h
download ftp://ftp.gmplib.org/pub/gmp-$VERSION/gmp-$VERSION.tar.bz2
#build gmp-$VERSION

# Build manually for now, as file needs removing and `make check` is important
tar jxf gmp-$VERSION.tar.bz2
cd gmp-$VERSION
rm mpn/x86_64/mod_34lsub1.asm
make || exit $?
make check || exit $?
make install || exit $?

