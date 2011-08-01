#!/bin/bash

set -a
VERSION=8.4.1
BASE=/usr/local/pgsql
set +a

. `dirname $0`/functions.sh
setup /usr/local/bin/pgbench

cd postgresql-$VERSION/contrib/pgbench

make || exit $?
make install || exit $?
