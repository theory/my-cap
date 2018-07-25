#!/bin/bash

export VERSION=0.19.8

. `dirname $0`/functions.sh

if [ "`/usr/local/bin/gettext --version | head -1 | awk '{print $4}'`" = $VERSION ]; then
    exit 0
fi
setup
download ftp://ftp.gnu.org/gnu/gettext/gettext-$VERSION.tar.gz
build gettext-$VERSION


