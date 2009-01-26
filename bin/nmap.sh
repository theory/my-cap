#!/bin/bash

export VERSION=4.76

. `dirname $0`/functions.sh

setup /usr/local/bin/nmap
download http://nmap.org/dist/nmap-$VERSION.tar.bz2
build nmap-$VERSION
