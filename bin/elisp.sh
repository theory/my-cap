#!/bin/bash

export MMMVERSION=0.4.8
export PODVERSION=0.4
export MDWNVERSION=0.6

. `dirname $0`/functions.sh

# Install mmm-mode.
setup
download http://softlayer.dl.sourceforge.net/sourceforge/mmm-mode/mmm-mode-$MMMVERSION.tar.gz
build mmm-mode-$MMMVERSION

# pod-mode
download http://cpan.org/authors/id/S/SC/SCHWIGON/pod-mode/pod-mode-$PODVERSION.tgz
rm -rf pod-mode-$PODVERSION
tar zxf pod-mode-$PODVERSION.tgz
cd pod-mode-$PODVERSION
emacs -batch -f batch-byte-compile pod-mode.el
cp pod-mode.el* 
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
download http://github.com/jrockway/cperl-mode/raw/moosex-declare/cperl-mode.el
emacs -batch -f batch-byte-compile *.el
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
download http://cpansearch.perl.org/src/SCHWIGON/emacs-tap-mode-0.02/tap-mode.el
emacs -batch -f batch-byte-compile tap-mode.el
cp tap-mode.el* /usr/local/share/emacs/site-lisp

# Return to src directory.
cd ..