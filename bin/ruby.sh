#!/bin/bash

export VERSION=1.9.3-p429

. `dirname $0`/functions.sh

setup /usr/local/lib/ruby/1.9.1
download ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$VERSION.tar.gz
build ruby-$VERSION
