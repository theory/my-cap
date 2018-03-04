#!/bin/bash

export VERSION=2.16.2
export CPPFLAGS="-I/usr/local/ssl/include"
export LDFLAGS="-L/usr/local/ssl/lib"

. `dirname $0`/functions.sh

if [ -f /usr/local/bin/git ]; then
    if [ `/usr/local/bin/git version | awk '{print $3}'` = "$VERSION" ]; then
        exit
    fi
fi

setup

# Download the Subversion dependencies.
rm -rf git-$VERSION
download https://www.kernel.org/pub/software/scm/git/git-$VERSION.tar.gz

# Build Git.
tar zxf git-$VERSION.tar.gz || exit $?
cd git-$VERSION
make prefix=/usr/local NO_GETTEXT=1 all
make prefix=/usr/local NO_GETTEXT=1 install
cd contrib/subtree
make prefix=/usr/local
make prefix=/usr/local install
cd ../..

# Download and install the docs.
download https://www.kernel.org/pub/software/scm/git/git-manpages-$VERSION.tar.gz
mkdir -p /usr/local/share/man
tar zx -C /usr/local/share/man -f git-manpages-$VERSION.tar.gz || exit $?

#rm -rf git-manpages-$VERSION
#download http://git-core.googlecode.com/files/git-manpages-$VERSION.tar.gz
#sudo tar xzv -C /usr/local/share/man -f git-manpages-$VERSION.tar.gz
