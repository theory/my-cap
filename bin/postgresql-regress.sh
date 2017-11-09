#!/bin/sh

. `dirname $0`/functions.sh

export PERL=/usr/bin/perl

setup
for VERSION in 10.1 9.6.6 9.5.10 9.4.15 9.3.20 9.2.24 9.1.24 # 9.0.19 8.4.22 8.3.23 8.2.23 8.1.23 8.0.26
do
    BASE=/usr/local/pgsql-`perl -E 'my @p = split /[.]/, $ARGV[0]; pop @p; print join ".", @p' $VERSION`
    DOC=$BASE/share/doc/html/release-`perl -e "\\$f = shift; \\$f =~ s/[.]0$//; \\$f =~ s/[.]/-/g; print \\$f;" $VERSION`.html
    if [ ! -f "$DOC" ]; then
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
        sudo make install-world || exit $?

        # Build PGDATA.
        if [ ! -e "$BASE/data" ]; then
            sudo mkdir $BASE/data || exit $?
            sudo chown -R postgres:postgres $BASE/data
            sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding UNICODE -D $BASE/data
            sudo mkdir $BASE/data/logs || exit $?
            sudo chown -R postgres:postgres $BASE/data/logs
        fi
        cd ..
    fi
done

# Older versions need more shared memory allocated.
if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
    echo kern.sysv.shmmax=167772160 >> /etc/sysctl.conf
    echo kern.sysv.shmmin=1         >> /etc/sysctl.conf
    echo kern.sysv.shmmni=32        >> /etc/sysctl.conf
    echo kern.sysv.shmseg=8         >> /etc/sysctl.conf
    echo kern.sysv.shmall=65536     >> /etc/sysctl.conf
    sysctl -w kern.sysv.shmmax=167772160
    sysctl -w kern.sysv.shmmin=1
    sysctl -w kern.sysv.shmmni=32
    sysctl -w kern.sysv.shmseg=8
    sysctl -w kern.sysv.shmall=65536
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
