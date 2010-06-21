#!/bin/sh

export VERSION=0.60.6
export DICT_VERSION=6-en-6.0-0

. `dirname $0`/functions.sh

setup /usr/local/include/aspell.h
download http://ftp.gnu.org/gnu/aspell/aspell-$VERSION.tar.gz
build aspell-$VERSION

cd aspell-$VERSION
ldconfig
cp scripts/ispell /usr/local/bin 
cp scripts/spell /usr/local/bin 
chmod +x /usr/local/bin/ispell
chmod +x /usr/local/bin/spell
cd ..

download ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell$DICT_VERSION.tar.bz2
build aspell$DICT_VERSION
