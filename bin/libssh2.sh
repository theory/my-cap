#!/bin/bash

export VERSION=1.2

. `dirname $0`/functions.sh

setup #/usr/local/include/libxml2/libxml/parser.h
download http://www.libssh2.org/download/libssh2-$VERSION.tar.gz
build libssh2-$VERSION
