#!/bin/bash

export VERSION=1.31-rc8

. `dirname $0`/functions.sh

setup /usr/local/lib/perl5/site_perl/5.10.0/darwin-2level/mod_perl.pm "VERSION = \"$VERSION\";"
download http://people.apache.org/~gozer/mp1/mod_perl-$VERSION.tar.gz
#download http://perl.apache.org/dist/mod_perl-$VERSION.tar.gz
rm -rf mod_perl-$VERSION
tar zxf mod_perl-$VERSION.tar.gz || exit $?
cd mod_perl-$VERSION
perl Makefile.PL \
  USE_APXS=1 \
  WITH_APXS=/usr/local/apache/bin/apxs \
  USE_DSO=1 \
  EVERYTHING=1 || exit $?
( make && make install UNINST=1 ) || exit $?
cd ..
