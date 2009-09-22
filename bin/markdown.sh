#!/bin/bash

export DVERSION=1.5.5
export MVERSION=1.0.1
. `dirname $0`/functions.sh

setup
download http://daringfireball.net/projects/downloads/Markdown_$MVERSION.zip
unzip Markdown_$MVERSION.zip || exit $?
cp Markdown_$MVERSION/Markdown.pl /usr/local/bin
chmod +x /usr/local/bin/Markdown.pl

download http://www.pell.portland.or.us/%7Eorc/Code/markdown/discount-$DVERSION.tar.gz
tar zxf discount-$DVERSION.tar.gz || exit $?
cd discount-$DVERSION || exit $?
./configure.sh || exit $?
make || exit $?
make install || exit $?
