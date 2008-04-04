#!/bin/bash

export VERSION=3.6.6

. `dirname $0`/functions.sh

if [ ! -d /usr/local/rt3 ]; then
    addgroup rt3
fi

setup /usr/local/rt3/asdfasdf
download http://download.bestpractical.com/pub/rt/release/rt-$VERSION.tar.gz
rm -rf rt-$VERSION
tar zxf rt-$VERSION.tar.gz || exit $?
cd rt-$VERSION
export PERL=/usr/local/bin/perl
./configure \
  --with-db-type=Pg \
  --with-db-rt-host=rt.kineticode.com \
  --with-db-dba=postgres \
  --with-web-user=nobody \
  --with-web-group=nogroup \
  --with-rt-group=rt3 \
  --with-db-rt-user=rt3 \
  --prefix=/usr/local/rt3 || exit $?
perl sbin/rt-test-dependencies \
  --with-postgres \
  --with-modperl2 --install || exit $?

if [ -d /usr/local/rt3 ]; then
    make upgrade || exit $?
else
    make || exit $?
    make install || exit $?
    echo '' | make initialize-database || exit ?
fi
