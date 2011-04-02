#!/bin/sh

export BASE=/var/www/api.pgxn.org
export PERL=/usr/local/bin/perl
export VERSION=0.8.0
export SVERSION=0.8.0

cd github/pgxn-api-searcher
git fetch origin
git pull origin tag v$SVERSION
perl Build.PL
./Build
./Build test
./Build install --uninst 1
./Build realclean

cd ../www-pgxn
git pull
perl Build.PL
./Build
./Build test
./Build install --uninst 1
./Build realclean

# Pull or clone the repository.
if [ -d $BASE ]; then
    cd $BASE
    git fetch origin
    git pull origin tag v$VERSION
else
    cd `dirname $BASE`
    git clone git://github.com/theory/pgxn-api.git `basename $BASE`
fi

# Build it!
$PERL Build.PL
./Build

