#!/bin/bash
#
#
#
#
#
#
#
#

WORKING_DIR='/var/www/pixelpi/sslard/'
WEB_CONTEXT='www-data'
LOCKFILE='/var/www/pixelpi/sslard/.lockfile'
PID_DIR='/var/run/sslard'
CONFIG_DIR='/var/www/pixelpi/config'
CONFIG_FILE='/var/www/pixelpi/config/image-settings.cfg'

echo "sslard configuration script"

# make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# look for working directory existance
if [ ! -d "$WORKING_DIR" ]; then
	echo "Creating the sslard working directory: $WORKING_DIR"
	mkdir "$WORKING_DIR"
	echo "Setting ownership to $WEB_CONTEXT, permissions 0770"
	chown "$WEB_CONTEXT:$WEB_CONTEXT" "$WORKING_DIR"
	chmod 0770 "$WORKING_DIR"
fi

# look for lockfile existance
if [ ! -f "$LOCKFILE" ]; then
	echo "Creating the sslard lock file: $LOCKFILE"
	touch "$LOCKFILE"
	echo "Setting ownership to $WEB_CONTEXT, permissions 0660"
	chown "$WEB_CONTEXT:$WEB_CONTEXT" "$LOCKFILE"
    chmod 0660 "$LOCKFILE"
fi

# look for PID file directory
if [ ! -d "$PID_DIR" ]; then
    echo "Creating the sslard PID file directory: $PID_DIR"
    mkdir "$PID_DIR"
    echo "Setting ownership to $WEB_CONTEXT, permissions 0770"
    chown "$WEB_CONTEXT:$WEB_CONTEXT" "$PID_DIR"
    chmod 0770 "$PID_DIR"
fi

# look for config file directory
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating the sslard PID file directory: $CONFIG_DIR"
    mkdir "$CONFIG_DIR"
    echo "Setting ownership to $WEB_CONTEXT, permissions 0770"
    chown "$WEB_CONTEXT:$WEB_CONTEXT" "$CONFIG_DIR"
    chmod 0770 "$CONFIG_DIR"
fi

# look for default configuration existance
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating the sslard default configuration file: $CONFIG_FILE"
    cp './image-settings.cfg' $CONFIG_FILE
    echo "Setting ownership to $WEB_CONTEXT, permissions 0660"
    chown "$WEB_CONTEXT:$WEB_CONTEXT" "$CONFIG_FILE"
    chmod 0660 "$CONFIG_FILE"
fi


echo "...done"


