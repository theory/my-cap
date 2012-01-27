#!/bin/bash

export VERSION=2.0.16

. `dirname $0`/functions.sh

setup /usr/local/include/event2/event-config.h "_EVENT_VERSION \"$VERSION"
download https://github.com/downloads/libevent/libevent/libevent-$VERSION-stable.tar.gz
build libevent-$VERSION-stable
