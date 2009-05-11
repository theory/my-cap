#!/bin/bash

export VERSION=1.6.3

. `dirname $0`/functions.sh

if [ -f /usr/local/git/bin/git ]; then
    if [ `/usr/local/git/bin/git version | awk '{print $3}'` = "$VERSION" ]; then
        exit
    fi
fi

setup

# Download the Subversion dependencies.
rm -rf git-$VERSION
download http://kernel.org/pub/software/scm/git/git-$VERSION.tar.bz2
build git-$VERSION

rm -rf git-manpages-$VERSION
download http://kernel.org/pub/software/scm/git/git-manpages-$VERSION.tar.bz2
sudo tar xjv -C /usr/local/share/man -f git-manpages-$VERSION.tar.bz2
