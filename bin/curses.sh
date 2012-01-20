#!/bin/bash

export VERSION=5.9

. `dirname $0`/functions.sh

setup /usr/local/include/ncurses/curses.h "NCURSES_VERSION \"$VERSION\""
download http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$VERSION.tar.gz
build ncurses-$VERSION
