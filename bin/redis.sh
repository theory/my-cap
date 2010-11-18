#!/bin/bash

#export VERSION=2.0.4
export VERSION=1.2.6

. `dirname $0`/functions.sh

setup /usr/local/bin/redis-server
download http://redis.googlecode.com/files/redis-$VERSION.tar.gz
tar zxf redis-$VERSION.tar.gz
cd redis-$VERSION
make
# These two work under 2.0:
# make test
# make install

# Just use these for 1.x:
cp redis-server /usr/local/bin/
cp redis-benchmark /usr/local/bin/
cp redis-cli /usr/local/bin/
cp redis-stat /usr/local/bin/

cd ..


