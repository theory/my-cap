#!/bin/sh

. `dirname $0`/functions.sh

export PERL=/usr/bin/perl

setup
for VERSION in 9.3.2 9.2.6 9.1.11 9.0.15 8.4.19 8.3.23 8.2.23 8.1.23 8.0.26
do
    BASE=/usr/local/pgsql-`echo $VERSION | awk -F. '{ print $1 "." $2 }'`
    if [ ! -e "$BASE" ]; then
        download http://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.bz2
        echo "Unpacking postgresql-$VERSION.tar.bz2"
        rm -rf postgresql-$VERSION
        tar jxf postgresql-$VERSION.tar.bz2 || exit $?
        cd postgresql-$VERSION
        ./configure --with-libs=/usr/local/lib --with-includes=/usr/local/include --prefix=$BASE --with-perl PERL=$PERL || exit $?
        make -j3 || exit $?
        sudo make install || exit $?

        # Install contrib modules
        cd contrib
        make -j3 || exit $?
        sudo make install || exit $?
        cd ..

        # Build PGDATA.
        sudo mkdir $BASE/data
        sudo chown -R postgres:postgres $BASE/data
        sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding UNICODE -D $BASE/data
        sudo mkdir $BASE/data/logs || exit $?
        sudo chown -R postgres:postgres $BASE/data/logs
        cd ..
    fi
done
