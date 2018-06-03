#!/bin/bash

export VERSION=6.1.2

. `dirname $0`/functions.sh

setup /usr/local/include/gmp.h
download ftp://ftp.gmplib.org/pub/gmp-$VERSION/gmp-$VERSION.tar.bz2
build gmp-$VERSION
make check || exit $?
