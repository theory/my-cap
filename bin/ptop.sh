#!/bin/bash

export VERSION=3.6.2-beta2

. `dirname $0`/functions.sh

setup /usr/local/bin/ptop
download http://pgfoundry.org/frs/download.php/1718/ptop-$VERSION.tar.bz2
build ptop-$VERSION
