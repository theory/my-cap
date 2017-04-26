#!/bin/bash

export VERSION=3.1.4

. `dirname $0`/functions.sh

setup # /usr/local/include/expat.h
download http://download.joedog.org/siege/siege-$VERSION.tar.gz
mkdir -p /usr/local/etc
build siege-$VERSION
#make check

export VERSION=1.02
download http://download.joedog.org/sproxy/sproxy-$VERSION.tar.gz
build sproxy-$VERSION
