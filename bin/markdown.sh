#!/bin/bash

export DVERSION=2.0.5
export ODVERSION=1.6.7
export MVERSION=1.0.1
. `dirname $0`/functions.sh

setup
download http://daringfireball.net/projects/downloads/Markdown_$MVERSION.zip
unzip Markdown_$MVERSION.zip || exit $?
cp Markdown_$MVERSION/Markdown.pl /usr/local/bin
chmod +x /usr/local/bin/Markdown.pl

download http://www.pell.portland.or.us/%7Eorc/Code/markdown/discount-$DVERSION.tar.bz2
tar jxf discount-$DVERSION.tar.bz2 || exit $?
cd discount-$DVERSION || exit $?
./configure.sh || exit $?
make || exit $?
make install || exit $?
cd ..

download http://www.pell.portland.or.us/%7Eorc/Code/markdown/discount-$ODVERSION.tar.bz2
tar jxf discount-$ODVERSION.tar.bz2 || exit $?
cd discount-$ODVERSION || exit $?
./configure.sh --prefix /usr/local/discount-$ODVERSION|| exit $?
make || exit $?
mkdir -p /usr/local/discount-$ODVERSION/bin
mkdir -p /usr/local/discount-$ODVERSION/lib
mkdir -p /usr/local/discount-$ODVERSION/include
make install || exit $?
cd ..
