#!/bin/bash

export MMMVERSION=0.4.8
export PODVERSION=0.4

. `dirname $0`/functions.sh

setup /usr/local/share/emacs/site-lisp/mmm-mode.el
download http://superb-west.dl.sourceforge.net/sourceforge/mmm-mode/mmm-mode-$MMMVERSION.tgz
build mmm-mode-$MMMVERSION

download http://cpan.org/authors/id/S/SC/SCHWIGON/pod-mode/pod-mode-$PODVERSION.tgz
rm -rf pod-mode-$PODVERSION
tar zxf pod-mode-$PODVERSION.tgz
cd pod-mode-$PODVERSION
emacs -batch -f batch-byte-compile pod-mode.el
cp pod-mode.el* /usr/local/share/emacs/site-lisp
cd ..

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
