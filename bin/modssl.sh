#!/bin/bash

export VERSION=2.8.30
export APACHEVERSION=1.39

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/perl.a
download http://www.modssl.org/source/mod_ssl-$VERSION-$APACHEVERSION.tar.gz
