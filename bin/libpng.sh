#!/bin/bash

export VERSION=1.5.4

. `dirname $0`/functions.sh

setup /usr/local/include/png.h
download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-$VERSION.tar.gz
build libpng-$VERSION
