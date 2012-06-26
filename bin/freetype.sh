#!/bin/bash

export VERSION=2.4.8

. `dirname $0`/functions.sh

if [ -e /usr/local/bin/freetype-config ] && [ "`/usr/local/bin/freetype-config --ftversion`" = $VERSION ]; then
    exit 0
fi
setup
download ftp://gnu.mirrors.pair.com/savannah/freetype/freetype-$VERSION.tar.bz2
build freetype-$VERSION
