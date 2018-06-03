#!/bin/bash

export VERSION=3.4

. `dirname $0`/functions.sh

setup
download https://ftp.gnu.org/gnu/nettle/nettle-$VERSION.tar.gz
build nettle-$VERSION
