#!/bin/bash

export VERSION=0.1.4

. `dirname $0`/functions.sh

setup /usr/local/include/yaml.h
download http://pyyaml.org/download/libyaml/yaml-$VERSION.tar.gz
build yaml-$VERSION

