#!/bin/bash

export VERSION=3.2.8

. `dirname $0`/functions.sh

setup /usr/local/bin/watch
download http://procps.sourceforge.net/procps-$VERSION.tar.gz
cd procps-$VERSION
gcc -L/usr/local/lib -I/usr/local/include -lncurses -o watch watch.c
install -d -m 755 /usr/local/bin
install -c -m 755 watch /usr/local/bin/
install -d -m 755 /usr/local/share/man/man1
install -c -m 755 watch.1 /usr/local/share/man/man1/


