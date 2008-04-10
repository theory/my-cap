#!/bin/bash

export VERSION=3.6.2-beta3

. `dirname $0`/functions.sh

setup /usr/local/bin/pg_top
download http://pgfoundry.org/frs/download.php/1738/pg_top-$VERSION.tar.bz2
build pg_top-$VERSION
