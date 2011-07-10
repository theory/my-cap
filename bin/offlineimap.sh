#!/bin/bash

echo `dirname $0`

. `dirname $0`/functions.sh

# http://software.complete.org/offlineimap
# http://software.complete.org/offlineimap/downloads

export VERSION='5.99.4'

setup /usr/local/bin/offlineimap
download http://software.complete.org/offlineimap/static/download_area/$VERSION/offlineimap_$VERSION.tar.gz
rm -rf offlineimap
tar zxf offlineimap_$VERSION.tar.gz
cd offlineimap
/usr/local/bin/python setup.py install
cd ..
