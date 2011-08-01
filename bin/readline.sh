#!/bin/bash

export VERSION=6.2

. `dirname $0`/functions.sh

setup /usr/local/include/readline/readline.h
download ftp://ftp.cwru.edu/pub/bash/readline-$VERSION.tar.gz
tar zxf readline-$VERSION.tar.gz
cd readline-$VERSION
perl -i -pe 's{\Qdarwin[89]*|darwin10*)}{darwin[89]*|darwin1[01]*)}' support/shobj-conf
./configure
make
make install

