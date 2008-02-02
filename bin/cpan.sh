#!/bin/bash

mkdir -p ~/.cpan/CPAN
cp `dirname $0`/../config/CPANConfig.pm ~/.cpan/CPAN/MyConfig.pm
mkdir -p '~/Library/Application Support/.cpan/CPAN'
cp `dirname $0`/../config/CPANConfig.pm '~/Library/Application Support/.cpan/CPAN/MyConfig.pm'


