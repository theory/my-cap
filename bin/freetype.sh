#!/bin/bash

export VERSION=2.3.9

. `dirname $0`/functions.sh

if [ -e /usr/local/bin/freetype-config ] && [ "`/usr/local/bin/freetype-config --ftversion`" = $VERSION ]; then
    exit 0
fi
setup
download http://mirrors.zerg.biz/nongnu/freetype/freetype-$VERSION.tar.bz2
build freetype-$VERSION
