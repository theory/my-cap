#!/bin/bash

export VERSION=5.0.51a-osx10.5-x86

setup 5.0.51a-osx10.5-x86_64
download ftp://mirror.x10.com/mysql/Downloads/MySQL-5.0/mysql-$VERSION.dmg

# Install it.

# Start up and add time zones.
/usr/local/mysql/bin/mysqld_safe &
/usr/local/mysql/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | /usr/local/mysql/bin/mysql -u root mysql

# Shut down and configure.
/usr/local/mysql/bin/mysqladmin -u root shutdown
cp `dirname $0`/../config/my.cnf /etc
