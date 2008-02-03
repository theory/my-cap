#!/bin/sh

export VERSION=22.1

. `dirname $0`/functions.sh

setup /Applications/Emacs.app/Contents/MacOS/Emacs
download http://ftp.gnu.org/pub/gnu/emacs/emacs-$VERSION.tar.gz
rm -rf emacs-$VERSION
tar zxf emacs-$VERSION.tar.gz
cd emacs-$VERSION
patch -p1 < `dirname $0`/../patches/emacs-22.1-10.5.patch
#./configure --with-carbon --without-x
./configure --with-carbon --without-x --without-pop --with-xpm --with-jpeg --with-tiff --with-png --with-gif --with-x-toolkit=lucid
# Might need to apply http://article.gmane.org/gmane.emacs.bugs/16867
make
sudo make install
cp -rf Mac/Emacs.app /Applications
rm /usr/local/bin/emacs
echo '#!/bin/sh' > /usr/local/bin/emacs
echo '/Applications/Emacs.app/Contents/MacOS/Emacs "$@"' >> /usr/local/bin/emacs
chmod +x /usr/local/bin/emacs
rm /usr/bin/emacs
ln /usr/local/bin/emacs /usr/bin
