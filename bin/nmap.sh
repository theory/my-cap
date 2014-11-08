#!/bin/bash

export VERSION=6.47

. `dirname $0`/functions.sh

setup /usr/local/bin/nmap
download http://nmap.org/dist/nmap-$VERSION.tar.bz2
build nmap-$VERSION
