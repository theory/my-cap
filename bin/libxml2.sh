#!/bin/bash

export VERSION=2.7.4

. `dirname $0`/functions.sh

setup /usr/local/include/libxml2/libxml/parser.h
download ftp://xmlsoft.org/libxml2/libxml2-$VERSION.tar.gz
build libxml2-$VERSION
