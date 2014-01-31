#!/bin/sh

export VERSION=1.1
export PERL=/usr/local/bin/perl
export BASE=/usr/local/pgxc

. `dirname $0`/functions.sh

setup $BASE/share/doc/html/release-`perl -e "\\$f = '$VERSION'; \\$f =~ s/[.]0$//; \\$f =~ s/[.]/-/g; print \\$f;"`.html
#download http://hivelocity.dl.sourceforge.net/project/postgres-xc/Version_$VERSION/pgxc-v$VERSION.tar.gz

download http://downloads.sourceforge.net/project/postgres-xc/Version_$VERSION/pgxc-v$VERSION.tar.gz
echo Unpacking $file...
rm -rf pgxc-v$VERSION
tar zxf pgxc-v$VERSION.tar.gz || exit $?
cd postgres-xc

if [ $OS = 'Darwin' ]; then
     # For debugging: --enable-cassert --enable-debug
    ./configure --with-bonjour --with-perl PERL=$PERL \
    --with-openssl --with-pam --with-krb5 --with-libxml \
    --with-ossp-uuid --with-includes=/usr/local/include \
    --enable-integer-datetimes --with-zlib \
    --with-libs=/usr/local/lib --prefix=$BASE || exit $?
else
    ./configure --with-perl PERL=$PERL --with-libxml --prefix=$BASE || exit $?    
fi

make all -j3 || exit $?
make -C contrib all -j3 || exit $?
make -C contrib/uuid-ossp all -j3 || exit $?
make DESTDIR=$BASE install || exit $?

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
    # mkdir -p /Library/StartupItems/PostgreSQL
    # cp contrib/start-scripts/osx/PostgreSQL /Library/StartupItems/PostgreSQL
    # perl -i -pe 's/ROTATELOGS=1/ROTATELOGS=/' /Library/StartupItems/PostgreSQL/PostgreSQL
    # cp contrib/start-scripts/osx/StartupParameters.plist /Library/StartupItems/PostgreSQL
    # if [ "`grep POSTGRESQL /etc/hostconfig`" = '' ]; then
    #     echo "POSTGRESQL=-YES-" >> /etc/hostconfig
    # fi

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
else
    if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
        sysctl -w kern.sysv.shmmax=167772160
        sysctl -w kern.sysv.shmmin=1
        sysctl -w kern.sysv.shmmni=32
        sysctl -w kern.sysv.shmseg=8
        sysctl -w kern.sysv.shmall=65536
    fi
    useradd postgres -d /nonexistent
    # cp contrib/start-scripts/linux /etc/init.d/postgresql
    # chmod +x /etc/init.d/postgresql
    # # chkconfig --add postgresql    # redhat
    # update-rc.d postgresql defaults # debian
fi

if [ ! -d $BASE/data ]; then
    # Create and initialize the data directory.
    mkdir $BASE/data
    chmod 0700 $BASE/data
    chown -R postgres:postgres $BASE/data
    sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 --nodename=data -D $BASE/data
#    sudo -u postgres $BASE/bin/initdb --no-locale --encoding utf-8 -D $BASE/data
    mkdir $BASE/data/logs
    chown -R postgres:postgres $BASE/data/logs
    if [ $OS = 'Linux' ]; then
        # Keep the data in /var on Linux.
        mkdir -p /var/db
        mv $BASE/data /var/db/pgdata
        ln -s /var/db/pgdata $BASE/data
        # perl -i -pe 's{serverlog}{logs/logfile}' /etc/init.d/postgresql
        # perl -i -pe "s{$BASE/data}{/var/db/pgdata}g" /etc/init.d/postgresql
    fi
fi

if [ ! -d $BASE/coord ]; then
    # Create and initialize the data directory.
    mkdir $BASE/coord
    chmod 0700 $BASE/coord
    chown -R postgres:postgres $BASE/coord
    sudo -u postgres $BASE/bin/initdb --locale en_US.UTF-8 --encoding utf-8 --nodename=coord -D $BASE/coord
#    sudo -u postgres $BASE/bin/initdb --no-locale --encoding utf-8 -D $BASE/coord
    mkdir $BASE/coord/logs
    chown -R postgres:postgres $BASE/coord/logs
    if [ $OS = 'Linux' ]; then
        # Keep the data in /var on Linux.
        mkdir -p /var/db
        mv $BASE/coord /var/db/pgdata
        ln -s /var/db/pgdata $BASE/coord
        # perl -i -pe 's{serverlog}{logs/logfile}' /etc/init.d/postgresql
        # perl -i -pe "s{$BASE/coord}{/var/db/pgdata}g" /etc/init.d/postgresql
    fi
fi
