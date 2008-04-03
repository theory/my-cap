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
# Force APR to use /dev/urandom instead of /dev/random. Details on the issue
# I found are here: http://www.andrewsavory.com/blog/archives/001408.html
perl -i -pe 's{(/arandom\s+)/dev/random\s+}{$1}' srclib/apr/configure
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
 --with-ldap \
 --enable-ldap \
 --enable-auth-ldap \
 --enable-mods-shared="rewrite info worker proxy deflate mod_auth include ssl env mime-magic auth_digest expires dav dav_fs perl auth_ldap ldap"
make
make install
echo Apache $VERSION > /usr/local/apache2/logs/apache-$VERSION
