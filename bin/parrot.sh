#!/bin/bash

export VERSION=2.0.0

. `dirname $0`/functions.sh

setup /usr/local/include/expat.h
download http://ftp.parrot.org/releases/stable/2.0.0/parrot-$VERSION.tar.gz
build parrot-$VERSION
perl Configure.pl
make
make TEST_JOBS=3 test
make install
make install-dev
