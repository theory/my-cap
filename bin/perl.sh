#!/bin/bash

export VERSION=5.10.1

. `dirname $0`/functions.sh

setup /usr/local/bin/perl$VERSION
download http://www.cpan.org/src/perl-$VERSION.tar.bz2
rm -rf perl-$VERSION
tar jxf perl-$VERSION.tar.bz2 || exit $?
cd perl-$VERSION
sh Configure -des -Duseshrplib -Dusemultiplicity -Dusethreads -Dperladmin=david@kineticode.com -Dcf_email=david@kineticode.com || exit $?
# * -Dusershrplib required for embedding, e.g. PL/Perl.
# * -DDusemultiplicity required to allow multiple interpreters in one process,
#   e.g., to allow both PL/Perl and PL/PerlU functions to be used in a single
#   database connection.
# * For debugging Perl, add -Dprefix=/usr/local/perl-5.10.0.d -Doptimize='-g'
make -j3 || exit $?
#make test || exit $?
TEST_JOBS=3 make test_harness || exit $?
make install || exit $?
