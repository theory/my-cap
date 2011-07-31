#!/bin/bash

export VERSION=5.14.1

. `dirname $0`/functions.sh

setup /usr/local/bin/perl$VERSION
download http://cpan.cpantesters.org/src/perl-$VERSION.tar.gz
rm -rf perl-$VERSION
tar zxf perl-$VERSION.tar.gz || exit $?
cd perl-$VERSION

# Patch Perl for newer Xcode: https://github.com/gugod/App-perlbrew/issues/128
if [ $OS = 'Darwin' ]; then
    curl 'http://perl5.git.perl.org/perl.git/patch/60a655a1ee05c577268377c1135ffabc34dbff43?hp=17f2f4a89572b1fc2df3bb61fe31eaab28f9b315' | patch -p1
fi

sh Configure -des -Duseshrplib -Dusemultiplicity -Duseithreads -Dinc_version_list=none -Dperladmin=david@kineticode.com -Dcf_email=david@kineticode.com || exit $?
# * -Dusershrplib required for embedding, e.g. PL/Perl.
# * -Dusemultiplicity required to allow multiple interpreters in one process,
#   e.g., to allow both PL/Perl and PL/PerlU functions to be used in a single
#   database connection.
# * For a test build, add  -Dprefix='/usr/local/perl-5.12' or similar
# * For debugging Perl, add -Dprefix=/usr/local/perl-5.10.0.d -Doptimize='-g'
make -j3 || exit $?
make test || exit $?
#TEST_JOBS=3 make test_harness || exit $?
make install || exit $?
