#!/bin/bash

export VERSION=2.8.8

. `dirname $0`/functions.sh

setup
download http://easynews.dl.sourceforge.net/sourceforge/wxwindows/wxWidgets-$VERSION.tar.gz
cd wxWidgets-$VERSION
mkdir osx-build
cd osx-build
../configure --disable-shared --enable-unicode --with-opengl
make -j3
make install
