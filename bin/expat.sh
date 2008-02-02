#!/bin/bash

export VERSION=2.0.1

. `dirname $0`/functions.sh

setup /usr/local/include/expat.h
download http://easynews.dl.sourceforge.net/sourceforge/expat/expat-$VERSION.tar.gz
build expat-$VERSION
make check
