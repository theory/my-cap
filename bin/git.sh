#!/bin/bash

export VERSION=1.7.10

. `dirname $0`/functions.sh

if [ -f /usr/local/bin/git ]; then
    if [ `/usr/local/bin/git version | awk '{print $3}'` = "$VERSION" ]; then
        exit
    fi
fi

setup

# Download the Subversion dependencies.
rm -rf git-$VERSION
download http://git-core.googlecode.com/files/git-$VERSION.tar.gz
build git-$VERSION

rm -rf git-manpages-$VERSION
download http://git-core.googlecode.com/files/git-manpages-$VERSION.tar.gz
sudo tar xzv -C /usr/local/share/man -f git-manpages-$VERSION.tar.gz
