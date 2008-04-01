#!/bin/bash

OS=`uname`

setup() {
	if [ ! $FORCE ]; then
		if [ -f $1 ]; then
			exit
		fi
	fi

	mkdir -p /usr/local/src
	cd /usr/local/src
}

download() {
	file=`basename $1`
	if [ $FORCE ]; then
		rm -f $file
	fi

	if [ ! -f $file ]; then
        if [ $OS = 'Darwin' ]; then
		    curl -kO $1
		else
		    wget --no-check-certificate $1
	    fi
	fi
}

build() {
	if [ $2 ]; then
		rm -rf $2
	else
		rm -rf $1
	fi

	if [ -f $1.tar.gz ]; then
		tar zxf $1.tar.gz
	elif [ -f $1.tar.bz2 ]; then
		tar jxf $1.tar.bz2
	fi

	if [ $2 ]; then
		cd $2
	else
		cd $1
	fi

	./configure
	make
	make install
	cd ..
}

