#!/bin/bash

export VERSION=2.0.4

. `dirname $0`/functions.sh

setup /usr/local/bin/redis-server
download http://redis.googlecode.com/files/redis-$VERSION.tar.gz
tar zxf redis-$VERSION.tar.gz
cd redis-$VERSION
make
make test
make install
cd ..


