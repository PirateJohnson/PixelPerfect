#!/bin/bash
#
#	TODO - re-write script
#

echo "make sure you run this as root"

/bin/mkdir -p /opt/sslard/res

/bin/mkdir -p /opt/sslard/data

/bin/mkdir -p /opt/sslard/config

/bin/mkdir -p /opt/sslard/bin

/bin/mkdir /var/run/sslard

/bin/cp ./res/facedb.xml.orig /opt/sslard/res/facedb.xml

/bin/cp ./res/haarcascade_frontalface_alt.xml /opt/sslard/res/haarcascade_frontalface_alt.xml

/bin/cp ./config/image-settings.cfg /opt/sslard/config/image-settings.cfg

/bin/cp ./config/register-values.cfg /opt/sslard/config/register-values.cfg

/bin/cp ./sslard /opt/sslard/bin/sslard

/bin/cp ./sslard /usr/local/bin/sslard

#/bin/cp ./45-ftdi.rules /etc/udev/rules.d/45-ftdi.rules

/bin/touch /opt/sslard/res/train.txt

# testing PC has lockfile here
#/bin/touch /opt/sslard/.lockfile

# RPi has lock file here
/bin/touch /var/www/pixelpi/sslard/.lockfile

/bin/touch /opt/sslard/trainer.txt

/bin/chmod 0755 /opt/sslard/bin/sslard

/bin/chmod 0755 /usr/local/bin/sslard

/bin/chown halb:www-data -R /opt/sslard

/bin/chown halb:www-data /var/run/sslard

/bin/chown halb:www-data -R /var/www/pixelpi/
