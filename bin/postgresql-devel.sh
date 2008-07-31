#!/bin/sh

export VERSION=8.4devel
export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgsql-$VERSION

cd ~/dev/pgsql
make distclean
cvs up
# For debugging: --enable-cassert --enable-debug
./configure --with-libs=/usr/local/lib  --with-includes=/usr/local/include --prefix=/usr/local/pgsql-8.4devel --with-libxml
make
sudo make install
sudo mkdir $BASE/data
sudo chown -R postgres:postgres $BASE/data
sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 -D $BASE/data
sudo mkdir $BASE/data/logs
sudo chown -R postgres:postgres $BASE/data/logs
