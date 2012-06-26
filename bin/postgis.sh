#!/bin/bash

export VERSION=1.5.4

. `dirname $0`/functions.sh

setup /usr/local/pgsql/share/contrib/postgis-1.5/postgis.sql
download http://www.postgis.org/download/postgis-$VERSION.tar.gz
tar zxf postgis-$VERSION.tar.gz
cd postgis-$VERSION
./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config
make
make install
make distclean

