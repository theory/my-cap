#!/bin/bash

export VERSION=5.2.9

. `dirname $0`/functions.sh

setup /usr/local/bin/php
download http://us3.php.net/distributions/php-$VERSION.tar.bz2
rm -rf php-$VERSION
tar jxf php-$VERSION.tar.bz2 || exit $?
cd php-$VERSION
perl -i -pe 's{^(char\s+[*]yytext)}{//$1}' Zend/zend_language_scanner.c
./configure --prefix=/usr/local/php5 --with-apxs2=/usr/local/apache2/bin/apxs --with-config-file-scan-dir=/usr/local/php5/php.d --with-iconv --with-openssl=/usr --with-zlib=/usr --with-gd --with-zlib-dir=/usr --with-ldap --with-xmlrpc --with-iconv-dir=/usr --with-snmp=/usr --enable-exif --enable-wddx --enable-soap --enable-sqlite-utf8 --enable-ftp --enable-sockets --enable-dbase --enable-mbstring --enable-calendar --enable-bcmath --with-bz2=/usr --enable-fastcgi --enable-cgi --enable-zip --enable-pcntl --enable-shmop --enable-sysvsem --enable-sysvshm --enable-sysvmsg --with-curl --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --with-pgsql=/usr/local/pgsql --with-pdo-pgsql=/usr/local/pgsql --with-libxml-dir=shared,/usr/local/php5 --with-xsl --with-kerberos=/usr --with-jpeg-dir=/usr/local/php5 --with-png-dir=/usr/local/php5 --enable-gd-native-ttf --with-freetype-dir=/usr/local/php5 --with-iodbc=shared,/usr --with-gettext --with-xsl || exit $?
make || exit $?
make install || exit $?

