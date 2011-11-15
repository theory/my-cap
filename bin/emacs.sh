#!/bin/sh

export VERSION=23.3
export TARVERSION=23.3a

. `dirname $0`/functions.sh

# Download and unpack.
setup
download http://ftp.gnu.org/gnu/emacs/emacs-$TARVERSION.tar.gz
tar zxf emacs-$TARVERSION.tar.gz
cd emacs-$VERSION

# Patches from https://gist.github.com/1109223.
curl 'http://repo.or.cz/w/emacs.git/commitdiff_plain/c8bba48c5889c4773c62a10f7c3d4383881f11c1' | patch -p1
curl 'https://raw.github.com/gist/1098107' | patch -p1
curl 'https://raw.github.com/gist/1012927' | patch -p1
curl 'https://raw.github.com/gist/1101856' | patch -p1

# Make it so.
./configure --without-x --without-pop --with-xpm --with-jpeg --with-tiff --with-png --with-gif --with-x-toolkit=lucid --with-ns --without-dbus || exit $?
make -j3 || exit $?
sudo make install || exit $?

# Install the bundle and the shell script that points to it.
cp -rf nextstep/Emacs.app /Applications
rm /usr/local/bin/emacs
echo '#!/bin/sh' > /usr/local/bin/emacs
echo '/Applications/Emacs.app/Contents/MacOS/Emacs "$@"' >> /usr/local/bin/emacs
chmod +x /usr/local/bin/emacs
