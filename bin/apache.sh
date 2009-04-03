#!/bin/bash

export VERSION=1.3.41
export MODSSLVERSION=2.8.31

. `dirname $0`/functions.sh

setup /usr/local/apache/logs/apache-$VERSION

# Download Apache.
download http://apache.oregonstate.edu/httpd/apache_$VERSION.tar.bz2
rm -rf apache_$VERSION
tar jxf apache_$VERSION.tar.bz2

# Download and configure mod_ssl.
if [ ! $NOSSL ]; then
    download http://www.modssl.org/source/mod_ssl-$MODSSLVERSION-$VERSION.tar.gz
    rm -rf mod_ssl-$MODSSLVERSION-$VERSION
    tar zxf mod_ssl-$MODSSLVERSION-$VERSION.tar.gz
    cd mod_ssl-$MODSSLVERSION-$VERSION
    patch -p0 < `dirname $0`/../patches/mod_ssl_dylib.patch
    ./configure --with-ssl --with-mm --with-apache=/usr/local/src/apache_$VERSION

    # Build Apache
    cd ../apache_$VERSION
    ./configure \
      --with-layout=Apache \
      --enable-module=so \
      --enable-module=ssl \
      --enable-module=rewrite \
      --enable-module=expires \
      --without-execstrip
    make
    make certificate TYPE=dummy
    make install
else
    cd ../apache_$VERSION
    ./configure \
      --with-layout=Apache \
      --enable-module=so \
      --enable-module=rewrite \
      --enable-module=expires \
      --without-execstrip
    make
    make install
fi

echo Apache $VERSION > /usr/local/apache/logs/apache-$VERSION
cd ..
