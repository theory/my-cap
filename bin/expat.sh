#!/bin/bash

export VERSION=2.1.0

. `dirname $0`/functions.sh

setup /usr/local/include/expat.h
download http://downloads.sourceforge.net/project/expat/expat/$VERSION/expat-$VERSION.tar.gz
build expat-$VERSION
#make check
