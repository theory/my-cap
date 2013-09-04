#!/bin/bash

export VERSION=1.21

. `dirname $0`/functions.sh

setup /usr/local/share/groff/$VERSION
download ftp://ftp.gnu.org/gnu/groff/groff-$VERSION.tar.gz
build groff-$VERSION
