#!/bin/bash

export VERSION=2.69

. `dirname $0`/functions.sh

setup # /usr/local/include/expat.h
download ftp://ftp.joedog.org/pub/siege/siege-$VERSION.tar.gz
mkdir -p /usr/local/etc
build siege-$VERSION
#make check
