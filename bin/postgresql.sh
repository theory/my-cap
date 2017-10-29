#!/bin/sh

export VERSION=10.0
#export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgsql-10
export CPPFLAGS=-D_XOPEN_SOURCE
export PGUSER=postgres
export PGGROUP=postgres
export SHELLDIR=`pwd`

. `dirname $0`/functions.sh

setup $BASE/share/doc/html/release-`perl -e "\\$f = shift; \\$f =~ s/[.]0$//; \\$f =~ s/[.]/-/g; print \\$f;"`.html
download http://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.bz2
echo Unpacking $file...
rm -rf postgresql-$VERSION
tar jxf postgresql-$VERSION.tar.bz2 || exit $?
cd postgresql-$VERSION

# Useful tutorial from depesz:
# http://www.depesz.com/index.php/2010/02/26/installing-postgresql/

if [ $OS = 'Darwin' ]; then
     # For debugging: --enable-cassert --enable-debug
    ./configure --with-bonjour --with-perl PERL=$PERL \
    --with-pam --with-libxml \
    --with-uuid=e2fs --with-includes=/usr/local/include \
    --enable-integer-datetimes --with-zlib \
    --with-libs=/usr/local/lib --prefix=$BASE || exit $?
else
    ./configure --with-perl PERL=$PERL --with-openssl --with-pam \
    --with-libxml --with-uuid=e2fs --with-libs=/usr/local/lib \
    --enable-integer-datetimes --with-zlib --with-gnu-ld \
    --with-includes=/usr/local/include || exit $?    
fi

make world -j3 || exit $?
#LD_LIBRARY_PATH=./src/interfaces/libpq ./src/bin/pg_dump/pg_dumpall -U postgres > db.backup
#cd /usr/local/src/postgresql-$VERSION
make install-world || exit $?

if [ $OS = 'Darwin' ]; then
    if [ "`dscl . -list /Groups | grep ^postgres`" = '' ]; then
        ID=`echo \`(dscl . list /Groups gid|awk '{print $2}'|sort -n|tail -1)\`+1 | bc`
        # Create the "postgres" group.
        dscl . -create /Groups/postgres
        dscl . -create /Groups/postgres RealName 'PostgreSQL Server'
        dscl . -create /Groups/postgres RecordName 'postgres'
        dscl . -create /Groups/postgres Password '*'
        dscl . -create /Groups/postgres PrimaryGroupID $ID
    fi

    if [ "`dscl . -list /Users | grep ^postgres`" = '' ]; then
        # Create the "postgres" user.
        ID=`echo \`(dscl . list /Users UniqueID|awk '{print $2}'|sort -n|tail -1)\`+1 | bc`
        GID=`dscl . read /Groups/postgres PrimaryGroupID|awk '{print $2}'`
        dscl . -create /Users/postgres
        dscl . -create /Users/postgres UniqueID $ID
        dscl . -create /Users/postgres RecordName postgres
        dscl . -create /Users/postgres RealName 'PostgreSQL Server'
        dscl . -create /Users/postgres UserShell '/usr/bin/false'
        dscl . -create /Users/postgres Password '*'
        dscl . -create /Users/postgres NFSHomeDirectory '/var/empty'
        dscl . -create /Users/postgres PrimaryGroupID $GID
    fi
    # Set up the start script.
    cp $SHELLDIR/config/org.postgresql.postgresql.plist /Library/LaunchDaemons/
else
    if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
        sysctl -w kern.sysv.shmmax=167772160
        sysctl -w kern.sysv.shmmin=1
        sysctl -w kern.sysv.shmmni=32
        sysctl -w kern.sysv.shmseg=8
        sysctl -w kern.sysv.shmall=65536
    fi
    useradd postgres -d /nonexistent
    cp contrib/start-scripts/linux /etc/init.d/postgresql
    chmod +x /etc/init.d/postgresql
    # chkconfig --add postgresql    # redhat
    update-rc.d postgresql defaults # debian
fi

if [ ! -d $BASE/data ]; then
    # Create and initialize the data directory.
    mkdir $BASE/data
    chmod 0700 $BASE/data
    chown -R $PGUSER:$PGGROUP $BASE/data
    sudo -u $PGUSER $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 -D $BASE/data
#    sudo -u $PGUSER $BASE/bin/initdb --no-locale --encoding utf-8 -D $BASE/data
    mkdir $BASE/data/logs
    chown -R $PGUSER:$PGGROUP $BASE/data/logs
    if [ $OS = 'Linux' ]; then
        # Keep the data in /var on Linux.
        mkdir -p /var/db
        mv $BASE/data /var/db/pgdata
        ln -s /var/db/pgdata $BASE/data
        perl -i -pe 's{serverlog}{logs/logfile}' /etc/init.d/postgresql
        perl -i -pe "s{$BASE/data}{/var/db/pgdata}g" /etc/init.d/postgresql
    fi
fi

cp $BASE/data/postgresql.conf $BASE/data/postgresql.conf.default
if [ $OS = 'Darwin' ]; then
    cp $SHELLDIR/config/postgresql.conf $BASE/data/
    chown $PGUSER:$PGGROUP $BASE/data/postgresql.conf
    if [ -e $BASE/data/postmaster.pid ]; then
        launchctl unload /Library/LaunchDaemons/org.postgresql.postgresql.plist || exit $?
    fi
    launchctl load -w /Library/LaunchDaemons/org.postgresql.postgresql.plist || exit $?
else
    download https://raw.github.com/theory/my-cap/master/config/postgresql-mac.conf
    cp $SHELLDIR/postgresql-wolf.conf $BASE/data/postgresql.conf
    chown $PGUSER:$PGGROUP $BASE/data/postgresql.conf
    /etc/init.d/postgresql stop
    /etc/init.d/postgresql start || exit $?
fi
