#!/bin/sh

export MAJVER=3.5
export VERSION=$MAJVER.18

. `dirname $0`/functions.sh

# Download and unpack.
setup
download https://www.gnupg.org/ftp/gcrypt/gnutls/v$MAJVER/gnutls-$VERSION.tar.xz
tar zxf emacs-$TARVERSION.tar.xz
cd gnutls-$VERSION

# Make it so. (Currently can't find Nettle. :-().
build
