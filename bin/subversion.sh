#!/bin/sh

export VERSION=1.4.6

# Install Apache 2.
./apache2.sh

# Install Swig
./swig.sh

export GXX=yes
export PERL=/usr/local/bin/perl
export PYTHON2=/usr/local/bin/python
export RUBY=/usr/local/bin/ruby

# Download the Subversion dependencies.
curl -O http://subversion.tigris.org/tarballs/subversion-deps-$VERSION.tar.bz2
tar jxf subversion-deps-$VERSION.tar.bz2

# Install Subversion
wget http://subversion.tigris.org/tarballs/subversion-$VERSION.tar.bz2
tar jxf subversion-$VERSION.tar.bz2
cd subversion-$VERSION
mv /usr/local/lib/libsvn* /tmp
mv /usr/local/lib/libapr* /tmp
mv /usr/local/lib/libneon* /tmp
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
ln -s /usr/local/lib/svn-python/libsvn /usr/local/lib/python2.3/site-packages
ln -s /usr/local/lib/svn-python/svn /usr/local/lib/python2.3/site-packages 
cd ..
