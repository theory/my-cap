#!/bin/bash

mkdir -p /tmp/ssl
cd /tmp/ssl
wget https://svn.kineticode.com/cap/config/openssl.cnf

# Create the certificate authority certificate and its private key.
openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650 -config openssl.cnf

# Create the private key and certificate request.
perl -i -pe 's/^distinguished_name = ca_dn/distinguished_name = req_dn/' openssl.cnf
openssl req -new -nodes -keyout serverkey.pem -out serverreq.pem -config openssl.cnf -days 3650

# Sign the certificate.
openssl ca -batch -out server.pem.tmp -config openssl.cnf -infiles serverreq.pem

# Strip out the human-readable portion.
openssl x509 -in server.pem.tmp -out server.pem

# Copy the files to their new home.
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs
chmod 700 /etc/ssl/private

mv cacert.pem /etc/ssl/certs
mv server.pem /etc/ssl/certs
mv serverkey.pem /etc/ssl/private
chown 440 /etc/ssl/private/serverkey.pem
chgrp ssl-cert /etc/ssl/private/serverkey.pem