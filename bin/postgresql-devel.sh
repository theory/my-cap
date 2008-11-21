#!/bin/sh

export VERSION=8.4
export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgsql-$VERSION

cd ~/dev/pgsql
make distclean
cvs up
# For debugging: --enable-cassert --enable-debug
./configure --with-libs=/usr/local/lib  --with-includes=/usr/local/include --prefix=$BASE --with-libxml || exit $?
make || exit $?
sudo make install || exit $?
sudo mkdir $BASE/data || exit $?
sudo chown -R postgres:postgres $BASE/data || exit $?
sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 -D $BASE/data || exit $?
sudo mkdir $BASE/data/logs || exit $?
sudo chown -R postgres:postgres $BASE/data/logs || exit $?
