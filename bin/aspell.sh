#!/bin/sh

export VERSION=0.60.6.1
export DICT_VERSION=6-en-7.1-0

. `dirname $0`/functions.sh

setup /usr/local/include/aspell.h
download http://ftp.gnu.org/gnu/aspell/aspell-$VERSION.tar.gz
tar zxf aspell-$VERSION.tar.gz || exit $?
cd aspell-$VERSION
patch -p0 < $RUNDIR/patches/aspell.patch
./configure || exit $?
make -j3 || exit $?
ldconfig
cp scripts/ispell /usr/local/bin 
cp scripts/spell /usr/local/bin 
chmod +x /usr/local/bin/ispell
chmod +x /usr/local/bin/spell
cd ..

download ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell$DICT_VERSION.tar.bz2
build aspell$DICT_VERSION
