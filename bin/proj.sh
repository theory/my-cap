#!/bin/bash

export VERSION=4.7.0

. `dirname $0`/functions.sh

setup /usr/local/include/proj_api.h
download http://download.osgeo.org/proj/proj-$VERSION.tar.gz
build proj-$VERSION
