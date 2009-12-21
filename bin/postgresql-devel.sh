#!/bin/sh

export VERSION=devel
export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgsql-$VERSION

cd ~/dev/postgresql
if [ -f GNUmakefile ]; then
    make maintainer-clean
fi
git checkout master
git pull
rm -rf $BASE
# For debugging: --enable-cassert --enable-debug
./configure --with-libs=/usr/local/lib  --with-includes=/usr/local/include --prefix=$BASE --with-libxml  --with-ossp-uuid --with-perl PERL=$PERL || exit $?
make -j3 || exit $?
sudo make install || exit $?

# Install contrib modules
cd contrib
svn export https://svn.kineticode.com/citext/trunk citext
for dir in isn hstore uuid-ossp citext
do
    cd $dir
    make -j3 || exit $?
    sudo make install || exit $?
    make clean
    cd ..
done
cd ..

sudo mkdir $BASE/data || exit $?
sudo chown -R postgres:postgres $BASE/data || exit $?
sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 -D $BASE/data || exit $?
sudo mkdir $BASE/data/logs
sudo chown -R postgres:postgres $BASE/data/logs

# sudo mkdir $BASE/data/pg_log || exit $?
# sudo chown -R postgres:postgres $BASE/data/pg_log || exit $?

# for file in isn hstore uuid-ossp citext
# do
#     $BASE/bin/psql -XU postgres -f $BASE/share/contrib/$file.sql template1
#     $BASE/bin/psql -XU postgres -f $BASE/share/contrib/$file.sql postgres
# done
