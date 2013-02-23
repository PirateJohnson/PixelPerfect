/******************************************************
** FILE: std_devfs.h
**
** ABSTRACT:
**			This header file contains the public, 
**			system-wide, return status, default
**			locations, default parameters, and
**			configuration lookup strings.
**
** DOCUMENTS:
**			See the SDD, SRS, and SD for more information 
**
** AUTHOR:
**			Jonathan Lamb
**			pixel.perfect.asic@gmail.com
**
** CREATION DATE:
**			10 FEB 2013
**
** NOTES:			
**
*******************************************************/

#ifndef STD_DEFS_H
#define	STD_DEFS_H

// debugging flag - comment this out to remove all printing statements except for errors
//#define DEBUG_PRINT		1

// return status from the configuration interface
#define CONFIG_PASS			1
#define CONFIG_FAIL			-1

// return status from the image manipulation routines
#define IMAGE_PASS			1
#define IMAGE_FAIL			-1

// the system return status, this will be the program return status
#define SYS_PASS			0
#define SYS_FAIL			-1

// return status from the ftdi interface
#define FTDI_PASS			1
#define FTDI_FAIL			-1

// return status from the daemon interface
#define DAEM_PASS			1
#define DAEM_FAIL			-1

// daemon control flags
#define DAEMON_ARG_LIST		"q"
#define DAEMON_QUIT			'q'
#define DAEMON_PID_FILE		"sslard/sslard"
#define DAEMON_LOG_INDENT	"sslard"
#define DAEMON_IMAGE_LOCKFILE	"/var/www/pixelpi/sslard/.lockfile"

// logging strings
#define LOG_ERROR			"ERROR"
#define LOG_DEBUGS			"DEBUG"
#define LOG_WARN			"WARN"
#define IMAGE_LOG_PREFIX	"image routines"
#define FTDI_LOG_PREFIX		"FTDI interface"
#define CONFIG_LOG_PREFIX	"configuration interface"
#define DAEMON_LOG_PREFIX	"daemon interface"

// image device config file
#define DEVICE_CONFIG_FILE	"/var/www/pixelpi/config/image-settings.cfg"

// config file lookup strings
#define CONFIG_IMAGE_WIDTH	"IMAGE_WIDTH"
#define CONFIG_IMAGE_HEIGHT	"IMAGE_HEIGHT"
#define CONFIG_PIXEL_DEPTH	"PIXEL_DEPTH"
#define CONFIG_VENDOR_ID	"VENDOR_ID"
#define CONFIG_PRODUCT_ID	"PRODUCT_ID"
#define CONFIG_BAUDRATE		"BAUDRATE"
#define CONFIG_INTERFACE	"INTERFACE"


// only supporting 8 bit pixel depth as of 10 FEB 2013
#define SUPPORTED_PIXEL_DEPTH 8

// the image file name strings
// staging is what gets written to first
// once complete then staging gets mv'd to current to avoid interfering with other programs
#define	IMAGE_STAGING_FILE	"/tmp/staging-image.jpg"
#define	IMAGE_CURRENT_FILE	"/var/www/pixelpi/image_res/current-image.jpg"
#define IMAGE_CURRENT_PERMS	"0644"


// the COM port in which to expect the serial data
#define DEV_COM_PORT		"/dev/ttyUSB0"

// command to signal a new frame from the image device
#define NEW_FRAME_CMD		0x0F

#endif	/* STD_DEFS_H */

