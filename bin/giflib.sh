#!/bin/bash

export VERSION=4.1.6

. `dirname $0`/functions.sh

setup /usr/local/include/gif_lib.h
download http://superb-west.dl.sourceforge.net/sourceforge/giflib/giflib-$VERSION.tar.gz
build giflib-$VERSION
