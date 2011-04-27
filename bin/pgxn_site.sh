#!/bin/sh

export BASE=/var/www/pgxn.org
export PERL=/usr/local/bin/perl
export VERSION=0.6.3

# Pull or clone the repository.
if [ -d $BASE ]; then
    cd `dirname $BASE`
    git clone git://github.com/pgxn/pgxn-site.git `basename $BASE`
fi

# Build it!
cd $BASE
git fetch origin
git pull origin tag v$VERSION
$PERL Build.PL
./Build
