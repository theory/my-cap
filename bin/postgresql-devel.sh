#!/bin/sh

export VERSION=devel
export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgsql
export CPPFLAGS=-D_XOPEN_SOURCE

cd ~/dev/postgresql/postgresql
if [ -f GNUmakefile ]; then
    make maintainer-clean
fi
# git checkout master
#git pull
sudo rm -rf $BASE
# Add  --enable-cassert --enable-debug for debugging.
./configure --with-perl PERL=$PERL --with-openssl --with-pam \
    --with-libxml --with-uuid=e2fs --with-libs=/usr/local/lib \
    --with-includes=/usr/local/include || exit $?
make -j3 || exit $?
sudo make install || exit $?

# Install contrib modules
cd contrib
make -j3 || exit $?
sudo make install || exit $?
make clean
cd ..

sudo mkdir $BASE/data || exit $?
sudo chown -R postgres:postgres $BASE/data || exit $?
sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 -D $BASE/data || exit $?
sudo mkdir $BASE/data/logs
sudo chown -R postgres:postgres $BASE/data/logs
