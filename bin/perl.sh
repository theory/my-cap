#!/bin/bash

export VERSION=5.10.0

. `dirname $0`/functions.sh

setup /usr/local/bin/perl$VERSION
download http://www.cpan.org/src/perl-$VERSION.tar.gz
rm -rf perl-$VERSION
tar zxf perl-$VERSION.tar.gz || exit $?
cd perl-$VERSION
# Debugging Perl:
#sh Configure -des -Duseshrplib -Dprefix=/usr/local/perl-5.10.0.d -Doptimize='-g' || exit $?
sh Configure -des -Duseshrplib -Dperladmin=david@kineticode.com -Dcf_email=david@kineticode.com || exit $?
make || exit $?
make test || exit $?
make install || exit $?
