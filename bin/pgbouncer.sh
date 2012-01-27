#!/bin/bash

export VERSION=1.5

. `dirname $0`/functions.sh

setup /usr/local/share/doc/pgbouncer/NEWS "PgBouncer $VERSION"
download http://pgfoundry.org/frs/download.php/3197/pgbouncer-$VERSION.tar.gz
rm -rf pgbouncer-$VERSION
tar zxf pgbouncer-$VERSION.tar.gz
cd pgbouncer-$VERSION
./configure
make
make install

     INSTALL  pgbouncer /usr/local/bin
     INSTALL  README /usr/local/share/doc/pgbouncer
     INSTALL  NEWS /usr/local/share/doc/pgbouncer
     INSTALL  etc/pgbouncer.ini /usr/local/share/doc/pgbouncer
     INSTALL  etc/userlist.txt /usr/local/share/doc/pgbouncer
