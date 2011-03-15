#!/bin/sh

export BASE=/var/www/api.pgxn.org
export PERL=/usr/local/bin/perl
export VERSION=0.5.1

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

