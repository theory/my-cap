#!/bin/sh

export BASE=/var/www/manager.pgxn.org
export PERL=/usr/local/bin/perl
export ROOT=/var/www/master.pgxn.org
export PGXNUSER=pgxn
export VERSION=0.5.1

# Check for user ID.
id -u $PGXNUSER >/dev/null 2>&1
if [ $? -ne 0 ]; then
    useradd $PGXNUSER -d /nonexistent
fi

# Check for mirror root.
if [ ! -d $ROOT ]; then
    mkdir -p $ROOT
    chown -R $PGXNUSER:$PGXNUSER $ROOT
fi

# Pull or clone the repository.
if [ -d $BASE ]; then
    cd $BASE
    git pull origin tag v$VERSION
else
    cd `dirname $BASE`
    git clone git://github.com/theory/pgxn-manager.git `basename $BASE`
fi

# Create the config file.
cp conf/proxied.json conf/prod.json

# Build it!
$PERL Build.PL --db_super_user postgres \
               --db_client /usr/local/pgsql/bin/psql \
               --context prod
./Build
./Build db
