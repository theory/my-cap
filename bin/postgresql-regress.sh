#!/bin/sh

. `dirname $0`/functions.sh

setup
for VERSION in 8.2.13 8.1.17 8.0.21
do
    BASE=/usr/local/pgsql-`echo $VERSION | awk -F. '{ print $1 "." $2 }'`
    if [ ! -e "$BASE" ]; then
        download ftp://ftp10.us.postgresql.org/pub/postgresql/source/v$VERSION/postgresql-$VERSION.tar.bz2
        rm -rf postgresql-$VERSION
        tar jxf postgresql-$VERSION.tar.bz2 || exit $?
        cd postgresql-$VERSION
        ./configure --with-libs=/usr/local/lib --with-includes=/usr/local/include --prefix=$BASE || exit $?
        make || exit $?
        sudo make install || exit $?
        sudo mkdir $BASE/data
        sudo chown -R postgres:postgres $BASE/data
        sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding UNICODE -D $BASE/data
        sudo mkdir $BASE/data/logs || exit $?
        sudo chown -R postgres:postgres $BASE/data/logs
        cd ..
    fi
done
