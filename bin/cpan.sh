#!/bin/bash

. `dirname $0`/functions.sh

mkdir -p ~/.cpan/CPAN
mkdir ~p ~/.cpanreporter

if [ $OS = 'Darwin' ]; then
    cp `dirname $0`/../config/CPANConfig.pm ~/.cpan/CPAN/MyConfig.pm
    mkdir -p '~/Library/Application Support/.cpan/CPAN'
    cp `dirname $0`/../config/CPANConfig.pm '~/Library/Application Support/.cpan/CPAN/MyConfig.pm'
    cp `dirname $0`/../config/cpanreporter.ini ~/.cpanreporter/config.ini
else
    wget --no-check-certificate -O ~/.cpan/CPAN/MyConfig.pm https://svn.kineticode.com/cap/config/CPANConfig.pm
    perl -i -pe 's{/Users}{/home}g' ~/.cpan/CPAN/MyConfig.pm
    perl -i -pe 's{/bin/zsh}{/bin/bash}g' ~/.cpan/CPAN/MyConfig.pm
    wget --no-check-certificate -O ~/.cpanreporter/config.ini https://svn.kineticode.com/cap/config/cpanreporter.ini
fi

# Mac::Carbon currently has a failing test. Delete this section when fixed.
if [ $OS = 'Darwin' ]; then
    if [ ! -e /usr/local/lib/perl5/site_perl/5.10.0/darwin-2level/Mac/Carbon.pm ]; then
        cd /tmp
        curl -O http://www.cpan.org/modules/by-authors/id/CNANDOR/Mac-Carbon-0.77.tar.gz
        tar zxf Mac-Carbon-0.77.tar.gz
        cd Mac-Carbon-0.77
        perl Makefile.PL
        make
        sudo make install
        cd ..
        rm -rf Mac-Carbon-0.77
    fi
fi

/usr/local/bin/cpan CPAN::Reporter
env PERL_MM_USE_DEFAULT=1 /usr/local/bin/cpan Bundle::Theory
