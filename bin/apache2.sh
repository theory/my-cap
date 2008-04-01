#!/bin/bash

export VERSION=2.2.8

. `dirname $0`/functions.sh

setup /usr/local/apache2/logs/apache-$VERSION
download http://www.apache.org/dist/httpd/httpd-$VERSION.tar.gz
tar zxf httpd-$VERSION.tar.gz
cd httpd-$VERSION
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export CFLAGS="-DAP_UNSAFE_ERROR_LOG_UNESCAPED"
./configure \
 --prefix=/usr/local/apache2  \
 --with-mpm=prefork \
 --enable-dav \
 --enable-dav-fs \
 --enable-log-config \
 --enable-authn-file \
 --enable-authz-host \
 --enable-authz-group \
 --enable-authz-user \
 --enable-mods-shared="rewrite info worker proxy deflate mod_auth include ssl env mime-magic auth_digest expires dav dav_fs perl"
make
make install
echo Apache $VERSION > /usr/local/apache2/logs/apache-$VERSION
