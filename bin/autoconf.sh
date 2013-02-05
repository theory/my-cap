#!/bin/bash

export VERSION=2.69

. `dirname $0`/functions.sh

setup /usr/local/bin/autoconf
download http://ftp.gnu.org/gnu/autoconf/autoconf-$VERSION.tar.gz
build autoconf-$VERSION
#make check
