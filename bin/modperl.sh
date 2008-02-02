#!/bin/bash

export VERSION=1.31-rc2

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/libperl.so
download http://people.apache.org/~gozer/mp1/mod_perl-$VERSION.tar.gz
#download http://perl.apache.org/dist/mod_perl-$VERSION.tar.gz
rm -rf mod_perl-$VERSION
tar zxf mod_perl-$VERSION.tar.gz
cd mod_perl-$VERSION
USER=dougm /usr/local/bin/perl Makefile.PL \
  USE_APXS=1 \
  WITH_APXS=/usr/local/apache/bin/apxs \
  USE_DSO=1 \
  EVERYTHING=1
make
make test
make install UNINST=1
cd ..
