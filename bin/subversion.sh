#!/bin/bash

export VERSION=1.4.6
export GXX=yes
export PERL=/usr/local/bin/perl
export PYTHON2=/usr/bin/python
export RUBY=/usr/bin/ruby

. `dirname $0`/functions.sh

if [ -f /usr/local/bin/svn ]; then
    if [ `/usr/local/bin/svn --version --quiet` = "$VERSION" ]; then
        exit
    fi
fi

setup

# Download the Subversion dependencies.
download http://subversion.tigris.org/tarballs/subversion-deps-$VERSION.tar.bz2
tar jxf subversion-deps-$VERSION.tar.bz2

# Install Subversion
download http://subversion.tigris.org/tarballs/subversion-$VERSION.tar.bz2
tar jxf subversion-$VERSION.tar.bz2
cd subversion-$VERSION
./configure \
  --with-ssl \
  --with-apxs=/usr/local/apache2/bin/apxs
make
make install
make swig-py
make install-swig-py
make swig-pl
make check-swig-pl
make install-swig-pl
make swig-rb
make install-swig-rb
make check-swig-rb
if [ ! -e /usr/lib/python2.5/site-packages/libsvn ]; then
    ln -s /usr/local/lib/svn-python/libsvn /usr/lib/python2.5/site-packages
fi
if [ ! -e /usr/lib/python2.5/site-packages/svn ]; then
    ln -s /usr/local/lib/svn-python/svn /usr/lib/python2.5/site-packages
fi
cd ..
