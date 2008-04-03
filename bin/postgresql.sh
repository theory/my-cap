#!/bin/sh

export VERSION=8.3.1
export PERL=/usr/local/bin/perl

. `dirname $0`/functions.sh

setup /usr/local/pgsql/doc/html/release-`perl -e "\\$f = '$VERSION'; \\$f =~ s/[.]0$//; \\$f =~ s/[.]/-/g; print \\$f;"`.html
setup /usr/local/pgsql/bin/pg_config
download ftp://ftp10.us.postgresql.org/pub/postgresql/source/v$VERSION/postgresql-$VERSION.tar.bz2
rm -rf postgresql-$VERSION
tar jxf postgresql-$VERSION.tar.bz2 || exit $?
cd postgresql-$VERSION

# Append --enable-cassert for debugging C library development
if [ $OS = 'Darwin' ]; then
    ./configure --with-libedit-preferred --with-bonjour --with-perl PERL=$PERL \
    --with-openssl --with-pam --with-krb5 --with-libxml --with-ldap --with-ossp-uuid \
    --with-libs=/usr/local/lib --with-includes=/usr/local/include || exit $?
else
    ./configure --with-perl PERL=$PERL --with-openssl --with-pam --with-krb5 \
    --with-libxml --with-ldap --with-ossp-uuid --with-libs=/usr/local/lib \
    --with-includes=/usr/local/include || exit $?    
fi

make || exit $?
#D_LIBRARY_PATH=./src/interfaces/libpq ./src/bin/pg_dump/pg_dumpall -U postgres > db.backup
make install || exit $?

# Install contrib modules
cd contrib
for dir in adminpack isn fuzzystrmatch hstore pgcrypto dblink intagg lo ltree pg_standby uuid-ossp
do
    cd $dir
    make || exit $?
    make install || exit $?
    cd ..
done
cd ..

if [ $OS = 'Darwin' ]; then
    if [ "`dscl . -list /Groups | grep postgres`" = '' ]; then
        ID=`echo \`(dscl . list /Groups gid|awk '{print $2}'|sort -n|tail -1)\`+1 | bc`
        # Create the "postgres" group.
        dscl . -create /Groups/postgres
        dscl . -create /Groups/postgres RealName 'PostgreSQL Server'
        dscl . -create /Groups/postgres RecordName 'postgres'
        dscl . -create /Groups/postgres Password '*'
        dscl . -create /Groups/postgres PrimaryGroupID $ID
    fi

    if [ "`dscl . -list /Users | grep postgres`" = '' ]; then
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

    if [ ! -e /Library/StartupItems/PostgreSQL ]; then
        mkdir -p /Library/StartupItems/PostgreSQL
        cp contrib/start-scripts/osx/PostgreSQL /Library/StartupItems/PostgreSQL
        cp contrib/start-scripts/osx/StartupParameters.plist /Library/StartupItems/PostgreSQL
        if [ "`grep POSTGRESQL /etc/hostconfig`" = '' ]; then
            echo "POSTGRESQL=-YES-" >> /etc/hostconfig
        fi
    fi

    if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
        echo kern.sysv.shmmax=167772160 >> /etc/sysctl.conf
        echo kern.sysv.shmmin=1         >> /etc/sysctl.conf
        echo kern.sysv.shmmni=32        >> /etc/sysctl.conf
        echo kern.sysv.shmseg=8         >> /etc/sysctl.conf
        echo kern.sysv.shmall=65536     >> /etc/sysctl.conf
    else
        cp `dirname $0`/../config/postgresql.conf /usr/local/pgsql/conf
        chown postgres:postgrs /usr/local/pgsql/conf
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
    download https://svn.kineticode.com/cap/config/postgresql.conf
    cp postgresql.conf /usr/local/pgsql/conf
    chown postgres:postgres /usr/local/pgsql/conf
    cp contrib/start-scripts/linux /etc/init.d/postgresql
    chmod +x /etc/init.d/postgresql
    # chkconfig --add postgresql    # redhat
    update-rc.d postgresql defaults # debian
fi

if [ ! -d /usr/local/pgsql/data ]; then
    # Create and initialize the data directory.
    mkdir /usr/local/pgsql/data
    chown -R postgres:postgres /usr/local/pgsql/data
    sudo -u postgres /usr/local/pgsql/bin/initdb --no-locale --encoding utf-8 -D /usr/local/pgsql/data
    mkdir /usr/local/pgsql/data/logs
    chown -R postgres:postgres /usr/local/pgsql/data/logs
fi

if [ $OS = 'Darwin' ]; then
    SystemStarter restart PostgreSQL
else
    /etc/init.d/postgresql start
fi
sleep 5

for lang in plpgsql plperl plperlu
do
    /usr/local/pgsql/bin/createlang -U postgres $lang template1
    /usr/local/pgsql/bin/createlang -U postgres $lang postgres
done

for file in adminpack fuzzystrmatch hstore isn pgcrypto dblink lo ltree uuid-ossp
do
    /usr/local/pgsql/bin/psql -U postgres -f /usr/local/pgsql/share/contrib/$file.sql template1
    /usr/local/pgsql/bin/psql -U postgres -f /usr/local/pgsql/share/contrib/$file.sql postgres
done

cd ..

if [ $OS = 'Darwin' ]; then
    if [ "`sysctl -n kern.sysv.shmmax`" -lt 167772160 ]; then
        cp `dirname $0`/../config/postgresql.conf /usr/local/pgsql/data
        chown postgres:postgrs /usr/local/pgsql/conf
        echo '###############################################################################'
        echo "Shared memory has been updated; changes will take effect after the next reboot."
        echo '###############################################################################'
    fi
fi