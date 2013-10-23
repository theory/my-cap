#!/bin/bash

export VERSION=2.8
export PATCH=12

. `dirname $0`/functions.sh

setup /usr/local/share/cmake-$VERSION/
download http://www.cmake.org/files/v$VERSION/cmake-$VERSION.$PATCH.tar.gz
build cmake-$VERSION.$PATCH
