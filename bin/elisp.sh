#!/bin/bash

export PODVERSION=1.04

# Use alt+x list-packages to install mmm-mode, sql-indent, go-mode, and markdown-mode.

. `dirname $0`/functions.sh
mkdir -p /usr/local/share/emacs/site-lisp

# pod-mode
download https://st.aticpan.org/source/FLORA/pod-mode-$PODVERSION/pod-mode.el
rm -rf pod-mode-$PODVERSION
tar zxf pod-mode-$PODVERSION.tar.gz
cd pod-mode-$PODVERSION
emacs -batch -f batch-byte-compile pod-mode.el
cp pod-mode.el* /usr/local/share/emacs/site-lisp
cd ..

# tap-mode
download https://github.com/renormalist/emacs-tap-mode/raw/master/tap-mode.el
emacs -batch -f batch-byte-compile tap-mode.el
cp tap-mode.el* /usr/local/share/emacs/site-lisp

# sqitch-mode
download https://raw.githubusercontent.com/christophermaier/sqitch-for-emacs/master/sqitch-mode.el
download https://raw.githubusercontent.com/christophermaier/sqitch-for-emacs/master/sqitch-plan-mode.el
emacs -batch -f batch-byte-compile sqitch-*.el
cp sqitch-*.el* /usr/local/share/emacs/site-lisp

# Return to src directory.
cd ..
