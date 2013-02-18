/******************************************************
** FILE: std_defs.h
**
** ABSTRACT:
** 
**
** DOCUMENTS:
** 
**
** AUTHOR:
** Jonathan Lamb
** pixel.perfect.asic@gmail.com
**
** CREATION DATE:
** 10 FEB 2013
**
** NOTES:
**
*******************************************************/

#ifndef STD_DEFS_H
#define	STD_DEFS_H

// debugging flag - comment this out to remove all printing statements except for errors
#define DEBUG_PRINT 1

// to avoid linking issues, define this if not already done so by OpenCV
#ifndef CV_RGB2GRAY
	#define CV_RGB2GRAY 7
#endif

// return status from the configuration interface
#define CONFIG_PASS		1
#define CONFIG_FAIL		-1

// return status from the image manipulation routines
#define IMAGE_PASS		1
#define IMAGE_FAIL		-1

// the system return status, this will be the program return status
#define SYS_PASS		0
#define SYS_FAIL		-1

// return status from the hardware interface
#define HW_PASS			1
#define HW_FAIL			-1

// logging strings
#define LOG_ERROR			"ERROR"
#define LOG_DEBUG			"DEBUG"
#define LOG_WARN			"WARN"
#define IMAGE_LOG_PREFIX	"image routines"
#define HW_LOG_PREFIX		"hardware interface"
#define CONFIG_LOG_PREFIX	"configuration interface"

// image device config file
#define DEVICE_CONFIG_FILE	"image-settings.cfg"

// config file lookup strings
#define CONFIG_IMAGE_WIDTH	"IMAGE_WIDTH"
#define CONFIG_IMAGE_HEIGHT	"IMAGE_HEIGHT"
#define CONFIG_PIXEL_DEPTH	"PIXEL_DEPTH"

// only supporting 8 bit pixel depth as of 10 FEB 2013
#define SUPPORTED_PIXEL_DEPTH 8

// the image file name strings
// staging is what gets written to first
// once complete then staging gets mv'd to current to avoid interfering with other programs
#define	IMAGE_STAGING_FILE	"staging-image.bmp"
#define	IMAGE_CURRENT_FILE	"current-image.bmp"


// the COM port in which to expect the serial data
#define DEV_COM_PORT		"/dev/ttyUSB0"

// command to signal a new frame from the image device
#define NEW_FRAME_CMD		0xFF

#endif	/* STD_DEFS_H */

