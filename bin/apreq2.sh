#!/bin/bash

export VERSION=2.12

. `dirname $0`/functions.sh

setup /usr/local/apache/libexec/libfoo.so
download http://apache.oregonstate.edu/httpd/libapreq/libapreq2-$VERSION.tar.gz
rm -rf libapreq2-$VERSION
tar zxf libapreq2-$VERSION.tar.gz || exit $?
cd libapreq2-$VERSION

# On 64 bit linux:
# LDFLAGS=-L/usr/lib64 ./configure --with-apache2-apxs=/usr/local/apache2/bin/apxs

./configure --with-apache2-apxs=/usr/local/apache2/bin/apxs || exit $?
make -j3 || exit $?
sudo make install || exit $?

/usr/local/bin/perl Makefile.PL --with-apache2-apxs=/usr/local/apache2/bin/apxs || exit $?
make -j3 || exit $?
#make test || exit $?
make install UNINST=1 || exit $?

# LoadModule apreq_module modules/mod_apreq2.so
if [ $OS = 'Darwin' ]; then
    if [ -z "`grep -l "apreq_module" "/usr/local/apache2/conf/httpd.conf"`" ]; then
        perl -i -pe 's/(LoadModule\s+rewrite_module.*)/$1\nLoadModule apreq_module modules\/mod_apreq2.so/' /usr/local/apache2/conf/httpd.conf
    fi
else    
    if [ -f /usr/local/apache2/modules/mod_apreq2.so ]; then
        perl -i -pe 's/^#\s+(LoadModule\s+apreq_module)/\\$1/m' /etc/httpd/httpd.conf;
    fi
fi

cd ..