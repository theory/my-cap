#!/bin/bash

export VERSION=2.0.4

. `dirname $0`/functions.sh

setup /usr/local/apache2/include/modperl_perl_includes.h "mod_perl/$VERSION"
download http://people.apache.org/~gozer/mp2/mod_perl-$VERSION.tar.gz
#download http://perl.apache.org/dist/mod_perl-$VERSION.tar.gz
tar zxf mod_perl-$VERSION.tar.gz
cd /tmp/mod_perl-$VERSION
/usr/local/bin/perl Makefile.PL \
  MP_AP_PREFIX=/usr/local/apache2 \
  MP_PROMPT_DEFAULT=1
make
make test
sudo make install

# LoadModule perl_module modules/mod_perl.so