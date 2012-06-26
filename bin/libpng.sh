#!/bin/bash

export VERSION=1.5.11 # the old version, 1.5.6, is no longer available by FTP

. `dirname $0`/functions.sh

setup /usr/local/include/png.h
download ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-$VERSION.tar.gz
build libpng-$VERSION
