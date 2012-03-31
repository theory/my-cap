#!/bin/bash

export VERSION=8.30

. `dirname $0`/functions.sh

if [ -f /usr/local/bin/pcre-config ]; then
    if [ `/usr/local/bin/pcre-config --version` = "$VERSION" ]; then
        exit
    fi
fi

setup

download ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$VERSION.tar.gz
build pcre-$VERSION
