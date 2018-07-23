#!/bin/sh

WORKDIR=$HOME/pg
SRCDIR=$WORKDIR/src

export PERL=/usr/bin/perl

. `dirname $0`/functions.sh

if [ ! -e $WORKDIR ]; then
    mkdir $WORKDIR
fi

if [ ! -e $SRCDIR ]; then
    mkdir $SRCDIR
fi


for VERSION in 10.4 9.6.9 9.5.13 9.4.18 9.3.23 9.2.24 9.1.24 # 9.0.19 8.4.22 8.3.23 8.2.23 8.1.23 8.0.26
do
    BASE=$WORKDIR/pgsql-`perl -E 'my @p = split /[.]/, $ARGV[0]; pop @p; print join ".", @p' $VERSION`
    DOC=$BASE/share/doc/html/release-`perl -e "\\$f = shift; \\$f =~ s/[.]0$//; \\$f =~ s/[.]/-/g; print \\$f;" $VERSION`.html
    if [ ! -f "$DOC" ]; then
        cd $SRCDIR
        download http://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.bz2
        echo "Unpacking postgresql-$VERSION.tar.bz2"
        rm -rf postgresql-$VERSION
        tar jxf postgresql-$VERSION.tar.bz2 || exit $?
        cd postgresql-$VERSION
        ./configure --with-libs=/usr/local/lib \
                    --with-includes=/usr/local/include \
                    --prefix=$BASE \
                    --with-perl PERL=$PERL || exit $?
        make world -j3 || exit $?
        make install-world || exit $?

        # Build PGDATA.
        if [ ! -e "$BASE/data" ]; then
            mkdir $BASE/data || exit $?
            $BASE/bin/initdb --locale en_US.UTF-8 --encoding UNICODE -D $BASE/data
            mkdir $BASE/data/logs || exit $?
        fi
        cd ..
    fi
done

# Older versions need more shared memory allocated.
if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
    sudo -c 'echo kern.sysv.shmmax=167772160 >> /etc/sysctl.conf'
    sudo -c 'echo kern.sysv.shmmin=1         >> /etc/sysctl.conf'
    sudo -c 'echo kern.sysv.shmmni=32        >> /etc/sysctl.conf'
    sudo -c 'echo kern.sysv.shmseg=8         >> /etc/sysctl.conf'
    sudo -c 'echo kern.sysv.shmall=65536     >> /etc/sysctl.conf'
    sudo sysctl -w kern.sysv.shmmax=167772160
    sudo sysctl -w kern.sysv.shmmin=1
    sudo sysctl -w kern.sysv.shmmni=32
    sudo sysctl -w kern.sysv.shmseg=8
    sudo sysctl -w kern.sysv.shmall=65536
fi

# Patch for 8.1
# --- src/pl/plperl/plperl.c.saf	2014-01-06 16:45:27.000000000 -0800
# +++ src/pl/plperl/plperl.c	2014-01-06 16:45:29.000000000 -0800
# @@ -694,7 +694,7 @@
#  		if (!isGV_with_GP(sv) || !GvCV(sv))
#  			continue;
#  		SvREFCNT_dec(GvCV(sv)); /* free the CV */
# -		GvCV(sv) = NULL;		/* prevent call via GV */
# +		GvCV_set(sv, NULL);		/* prevent call via GV */
#  	}
 
#  	hv_clear(stash);
