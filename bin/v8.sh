#!/bin/bash

export VERSION=3.20.9

. `dirname $0`/functions.sh

setup /usr/local/include/v8.h
download https://github.com/v8/v8/archive/$VERSION.tar.gz
tar zxf $VERSION.tar.gz
mv $VERSION v8-$VERSION
cd v8-$VERSION

make dependencies
make -j4 native library=shared snapshot=on console=readline
cp include/*.h /usr/local/include 
cd out/native
cp lib* /usr/local/lib/
cp d8 /usr/local/bin/
cp lineprocessor /usr/local/bin/
cp preparser /usr/local/bin/
cp process /usr/local/bin/
cp shell /usr/local/bin/v8
cp mksnapshot.* /usr/local/bin/
