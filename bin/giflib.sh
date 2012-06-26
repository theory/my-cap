#!/bin/bash

export VERSION=4.1.6

. `dirname $0`/functions.sh

setup /usr/local/include/gif_lib.h
download http://sourceforge.net/projects/giflib/files/giflib-4.x/giflib-4.1.6/giflib-4.1.6.tar.bz2
$VERSION/giflib-$VERSION.tar.bz2
build giflib-$VERSION
