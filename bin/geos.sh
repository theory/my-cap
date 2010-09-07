#!/bin/bash

export VERSION=3.2.2

. `dirname $0`/functions.sh

setup /usr/local/include/geos.h
download http://download.osgeo.org/geos/geos-$VERSION.tar.bz2
build geos-$VERSION
