#!/bin/bash

export VERSION=2.69

. `dirname $0`/functions.sh

setup # /usr/local/include/expat.h
download ftp://ftp.joedog.org/pub/siege/siege-$VERSION.tar.gz
mkdir -p /usr/local/etc
build siege-$VERSION
#make check

export VERSION=1.01
download ftp://sid.joedog.org/pub/sproxy/sproxy-$VERSION.tar.gz
build sproxy-$VERSION
