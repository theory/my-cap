#!/bin/bash

export VERSION=3.9.2

. `dirname $0`/functions.sh

setup /usr/local/include/tiff.h
download ftp://ftp.remotesensing.org/pub/libtiff/tiff-$VERSION.tar.gz
build tiff-$VERSION
