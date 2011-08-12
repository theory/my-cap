#!/bin/bash

export VERSION=2.2

. `dirname $0`/functions.sh

setup
download http://pgfoundry.org/frs/download.php/2949/plproxy-$VERSION.tar.gz
rm -rf plproxy-$VERSION
tar zxf plproxy-$VERSION.tar.gz
cd plproxy-$VERSION
make PG_CONFIG=/usr/local/pgsql/bin/pg_config
make install PG_CONFIG=/usr/local/pgsql/bin/pg_config
