#!/bin/bash

. `dirname $0`/functions.sh

setup

for VERSION in 5.10.1 5.8.9
do
    BASE=/usr/local/perl-`echo $VERSION | awk -F. '{ print $1 "." $2 }'`
    if [ ! -e "$BASE" ]; then
        download http://cpan.cpantesters.org/src/perl-$VERSION.tar.bz2
        echo "Unpacking perl-$VERSION.tar.bz2"
        rm -rf perl-$VERSION
        tar jxf perl-$VERSION.tar.bz2 || exit $?
        cd perl-$VERSION
        sh Configure -des -Dprefix=$BASE -Dperladmin=david@kineticode.com -Dcf_email=david@kineticode.com || exit $?
        make -j3 || exit $?
        make test
        make install || exit $?
        cd ..
    fi
done

# Special-case 5.6.2, which needs a little help (no bz2, needs configure help).
VERSION=5.6.2
BASE=/usr/local/perl-`echo $VERSION | awk -F. '{ print $1 "." $2 }'`
if [ ! -e "$BASE" ]; then
    download http://cpan.cpantesters.org/src/perl-$VERSION.tar.gz
    echo "Unpacking perl-$VERSION.tar.gz"
    rm -rf perl-$VERSION
    tar zxf perl-$VERSION.tar.gz || exit $?
    cd perl-$VERSION
    sh Configure -des -Dprefix=$BASE -Dperladmin=david@kineticode.com -Dcf_email=david@kineticode.com || exit $?
    perl -i -nle 'print unless /<(built-in|command(\s+|-)line)>/' GNUmakefile x2p/GNUmakefile
    make -j3 || exit $?
    make test
    make install || exit $?
    cd ..
fi
