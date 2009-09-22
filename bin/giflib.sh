#!/bin/bash

export VERSION=4.1.6

. `dirname $0`/functions.sh

setup /usr/local/include/gif_lib.h
download http://softlayer.dl.sourceforge.net/project/giflib/giflib%204.x/giflib-$VERSION/giflib-$VERSION.tar.bz2
build giflib-$VERSION
