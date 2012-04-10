#!/bin/bash

export VERSION=3.0.2

. `dirname $0`/functions.sh

if [ -f /usr/local/nginx/sbin/nginx ]; then
    if [ `/usr/local/nginx/sbin/nginx -v 2>&1 | awk -F / '{print $2}'` = "$VERSION" ]; then
        exit
    fi
fi

setup

download http://repo.varnish-cache.org/source/varnish-$VERSION.tar.gz
build varnish-$VERSION
ldconfig

# wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
# chmod +x /etc/init.d/nginx
# /usr/sbin/update-rc.d -f nginx defaults
# perl -i -pE 's{^DAEMON=.+}{DAEMON=/usr/local/nginx/sbin/nginx}' /etc/init.d/nginx
