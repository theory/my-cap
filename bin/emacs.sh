#!/bin/sh

export VERSION=26.1
export TARVERSION=$VERSION

echo Just download and install from https://emacsformacosx.com.
exit 1

. `dirname $0`/functions.sh

# Download and unpack.
setup
download http://ftp.gnu.org/gnu/emacs/emacs-$TARVERSION.tar.gz
tar zxf emacs-$TARVERSION.tar.gz
cd emacs-$VERSION

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
