#!/bin/bash

export VERSION=2.1

. `dirname $0`/functions.sh

setup
download http://pgfoundry.org/frs/download.php/2665/plproxy-$VERSION.tar.gz
tar zsf build plproxy-$VERSION.tar.gz
cd plproxy-$VERSION
perl -i -pe 's{(\Qint yyget_leng(void);\E)}{// $1}' src/scanner.l
make
make install
