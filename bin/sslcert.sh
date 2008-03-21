#!/bin/bash

mkdir -p /tmp/ssl
cd /tmp/ssl
wget --no-check-certificate https://svn.kineticode.com/cap/config/openssl.cnf
echo 01 > serial
touch index.txt

# Create the certificate authority certificate and its private key.
openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650 -config openssl.cnf

# Create the private key and certificate request.
perl -i -pe 's/^distinguished_name = ca_dn/distinguished_name = req_dn/' openssl.cnf
openssl req -new -nodes -keyout serverkey.pem -out serverreq.pem -config openssl.cnf -days 3650

# Sign the certificate.
openssl ca -batch -out servercert.pem.tmp -config openssl.cnf -infiles serverreq.pem

# Strip out the human-readable portion.
openssl x509 -in servercert.pem.tmp -out servercert.pem

# Create a client key and certificate request.
perl -i -pe 's/^nsCertType = server/nsCertType = client/' openssl.cnf
openssl req -new -nodes -keyout clientkey.pem -out clientreq.pem -config openssl.cnf -days 3650

# Sign the certificate.
openssl ca -batch -out clientcert.pem.tmp -config openssl.cnf -infiles clientreq.pem

# Strip out the human-readable portion.
openssl x509 -in clientcert.pem.tmp -out clientcert.pem

# Make sure that the SSL directories exist.
# XXX Modify for other OSs. This is for Ubuntu.
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs
chmod 710 /etc/ssl/private
chgrp ssl-cert /etc/ssl/private

# Copy the files to their new home.
cat serverkey.pem servercert.pem > /etc/ssl/private/serverkeycert.pem # Combined pem.
mv cacert.pem /etc/ssl/certs        # CA certifcate
mv servercert.pem /etc/ssl/certs    # wildcard server certificate
mv serverkey.pem /etc/ssl/private   # private key for wildcard certficate
mv clientcert.pem /etc/ssl/certs    # client certificate
mv clientkey.pem /etc/ssl/private   # private key for client certficate

# Set their permissions.
chmod 444 /etc/ssl/certs/cacert.pem
chmod 444 /etc/ssl/certs/servercert.pem
chmod 440 /etc/ssl/private/serverkey.pem
chmod 440 /etc/ssl/private/serverkeycert.pem
chmod 444 /etc/ssl/certs/clientcert.pem
chmod 440 /etc/ssl/private/clientkey.pem
chgrp ssl-cert /etc/ssl/private/serverkey.pem
chgrp ssl-cert /etc/ssl/private/serverkeycert.pem
chgrp ssl-cert /etc/ssl/private/clientkey.pem

# Delete the directory used to create them.
cd ..
rm -rf ssl
