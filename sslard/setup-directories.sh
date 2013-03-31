#!/bin/bash
#
#
#

echo "make sure you run this as root"

/bin/mkdir -p /opt/sslard/res

/bin/mkdir -p /opt/sslard/data

/bin/mkdir /var/run/sslard

/bin/touch /opt/sslard/res/facedb.xml

/bin/touch /opt/sslard/res/train.txt

/bin/touch /opt/sslard/.lockfile
#/bin/touch /var/www/pixelpi/sslard/.lockfile

/bin/touch /opt/sslard/trainer.txt

chown halb:www-data -R /opt/sslard

chown halb:www-data /var/run/sslard

#chown halb:www-data -R /var/www/pixelpi/
