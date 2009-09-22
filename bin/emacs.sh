#!/bin/sh

export VERSION=22.3

. `dirname $0`/functions.sh

#setup /Applications/Emacs.app/Contents/MacOS/Emacs
cd /usr/local/src
if [ ! -d emacs ]; then
    git clone git://git.sv.gnu.org/emacs || exit $?
fi
cd emacs
git pull || exit $?
# Get rid of the $CC setting once Emacs can be built with 64 bit support on Snow Leopard.
CC='gcc -arch i386' ./configure --with-carbon --without-x --without-pop --with-xpm --with-jpeg --with-tiff --with-png --with-gif --with-x-toolkit=lucid --with-ns || exit $?
make bootstrap -j3 || exit $?
make -j3 || exit $?
sudo make install || exit $?
cd nextstep
make install || exit $?
cp -rf Emacs.app /Applications
rm /usr/local/bin/emacs
echo '#!/bin/sh' > /usr/local/bin/emacs
echo '/Applications/Emacs.app/Contents/MacOS/Emacs "$@"' >> /usr/local/bin/emacs
chmod +x /usr/local/bin/emacs
rm /usr/bin/emacs
ln /usr/local/bin/emacs /usr/bin
