#!/bin/bash

export VERSION=2.2.1

. `dirname $0`/functions.sh

setup /usr/local/include/jansson.h $VERSION
download http://www.digip.org/jansson/releases/jansson-$VERSION.tar.gz
build jansson-$VERSION
make check
