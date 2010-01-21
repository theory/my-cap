#!/bin/bash

export MMMVERSION=0.4.8
export PODVERSION=0.502

. `dirname $0`/functions.sh
mkdir -p /usr/local/share/emacs/site-lisp

# Install mmm-mode.
setup
download http://softlayer.dl.sourceforge.net/project/mmm-mode/mmm-mode/$MMMVERSION/mmm-mode-$MMMVERSION.tar.gz
build mmm-mode-$MMMVERSION

# pod-mode
download http://cpan.org/authors/id/S/SC/SCHWIGON/pod-mode/pod-mode-$PODVERSION.tgz
rm -rf pod-mode-$PODVERSION
tar zxf pod-mode-$PODVERSION.tgz
cd pod-mode-$PODVERSION
emacs -batch -f batch-byte-compile pod-mode.el
cp pod-mode.el* /usr/local/share/emacs/site-lisp
cd ..

# ruby-mode
if [ -d ruby-mode ]; then
    cd ruby-mode
    rm -rf *.elc
    svn up
else
    svn co http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8/misc/ ruby-mode
    cd ruby-mode
fi
emacs -batch -f batch-byte-compile *.el
cp *.el* /usr/local/share/emacs/site-lisp
cd ..

mkdir -p elisp
cd elisp

# cperl-mode
download http://github.com/jrockway/cperl-mode/raw/mx-declare/cperl-mode.el
emacs -batch -f batch-byte-compile cperl-mode.el
cp cperl-mode.el* /usr/local/share/emacs/site-lisp

# markdown-mode
download http://code.jblevins.org/markdown-mode/markdown-mode.el
emacs -batch -f batch-byte-compile *.el
cp markdown-mode.el* /usr/local/share/emacs/site-lisp

# sql-indent
download http://www.geocities.com/kensanata/elisp/sql-indent.el.txt
mv sql-indent.el.txt sql-indent.el
emacs -batch -f batch-byte-compile *.el
cp sql-indent.el* /usr/local/share/emacs/site-lisp

# php-mode.
download http://php-mode.svn.sourceforge.net/svnroot/php-mode/tags/php-mode-1.5.0/php-mode.el
emacs -batch -f batch-byte-compile *.el
cp php-mode.el* /usr/local/share/emacs/site-lisp

# tap-mode
download http://github.com/renormalist/emacs-tap-mode/raw/master/tap-mode.el
emacs -batch -f batch-byte-compile tap-mode.el
cp tap-mode.el* /usr/local/share/emacs/site-lisp

# sql-indent
download http://www.astro.princeton.edu/~rhl/skyserver/sql-indent.el
emacs -batch -f batch-byte-compile sql-indent.el
cp sql-indent.el* /usr/local/share/emacs/site-lisp

# Return to src directory.
cd ..