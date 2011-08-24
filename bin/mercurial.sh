#!/bin/bash

export VERSION=1.9.1

. `dirname $0`/functions.sh

setup /usr/local/lib/python2.6/site-packages/mercurial/__version__.py $VERSION
download http://mercurial.selenic.com/release/mercurial-$VERSION.tar.gz
tar zxf mercurial-$VERSION.tar.gz
cd mercurial-$VERSION
make build
make install-bin
cd ..
