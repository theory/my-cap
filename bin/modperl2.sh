#!/bin/bash

export VERSION=2.0.4

. `dirname $0`/functions.sh

setup /usr/local/apache2/include/modperl_trace.h "MP_VERSION_STRING \"mod_perl/$VERSION\""
# download http://www.apache.org/~gozer/mp2/mod_perl-$VERSION.tar.gz
download http://perl.apache.org/dist/mod_perl-$VERSION.tar.gz
tar zxf mod_perl-$VERSION.tar.gz || exit $?
cd mod_perl-$VERSION
/usr/local/bin/perl Makefile.PL \
  MP_AP_PREFIX=/usr/local/apache2 \
  MP_PROMPT_DEFAULT=1 || exit $?
# Debugging mod_perl with debugging Perl:
#/usr/local/perl-5.10.0.d/bin/perl Makefile.PL \
#  MP_AP_PREFIX=/usr/local/apache2.d \
#  MP_MAINTAINER=1 \
#  MP_PROMPT_DEFAULT=1
( make -j3 && make test && make install UNINST=1) || exit $?

# LoadModule perl_module modules/mod_perl.so
if [ $OS = 'Darwin' ]; then
    if [ -z "`grep -l "mod_perl\.so" "/usr/local/apache2/conf/httpd.conf"`" ]; then
        /usr/local/bin/perl -i -pe 's/(LoadModule\s+rewrite_module.*)/$1\nLoadModule perl_module modules\/mod_perl.so/' /usr/local/apache2/conf/httpd.conf
    fi
else    
    if [ -f /usr/local/apache2/modules/mod_perl.so ]; then
        /usr/local/bin/perl -i -pe 's/^#\s+(LoadModule\s+perl_module)/\\$1/m' /etc/httpd/httpd.conf;
    fi
fi

