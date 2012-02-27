#!/bin/bash

export VERSION=8.6.6

. `dirname $0`/functions.sh

setup /usr/local/bin/asciidoc
download http://downloads.sourceforge.net/project/asciidoc/asciidoc/$VERSION/asciidoc-$VERSION.tar.gz
build asciidoc-$VERSION
#make check
