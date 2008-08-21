#!/bin/bash

export VERSION=1.2.8

. `dirname $0`/functions.sh

setup /usr/local/bin/markdown
download http://www.pell.portland.or.us/%7Eorc/Code/markdown/discount-$VERSION.tar.gz
tar zxf discount-$VERSION.tar.gz || exit $?
cd discount-$VERSION || exit $?
./configure.sh || exit $?
make || exit $?
make install || exit $?

