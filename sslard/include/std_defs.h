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

// TODO - move string defs to const

#ifndef STD_DEFS_H
#define	STD_DEFS_H

// debugging flag - comment this out to remove all printing statements except for errors
//#define DEBUG_PRINT			1

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

// return status from the vision module
#define VISION_PASS			1
#define VISION_FAIL			-1

// daemon control flags
extern const char* DAEMON_ARG_LIST;
extern const char DAEMON_QUIT;
extern const char DAEMON_CMD;
extern const char DAEMON_TRAIN;
extern const char* DAEMON_GUI_MODE;
extern const char* DAEMON_PID_FILE;
extern const char* DAEMON_LOG_INDENT;
extern const char* DAEMON_IMAGE_LOCKFILE;
extern const char* DAEMON_TRAIN_FILE;
// TODO - add RPI paths
// rpi lock file - /var/www/pixelpi/sslard/

// logging strings
extern const char* LOG_ERROR;
extern const char* LOG_DEBUGS;
extern const char* LOG_WARN;
extern const char* LOG_INFOS;
extern const char* DAEMON_LOG_PREFIX;

extern const char* IMAGE_LOG_PREFIX;
extern const char* VISION_LOG_PREFIX;
extern const char* FTDI_LOG_PREFIX;
extern const char* CONFIG_LOG_PREFIX;

// image device config file
extern const char* DEVICE_CONFIG_FILE;

// config file lookup strings
extern const char* CONFIG_IMAGE_WIDTH;
extern const char* CONFIG_IMAGE_HEIGHT;
extern const char* CONFIG_PIXEL_DEPTH;
extern const char* CONFIG_VENDOR_ID;
extern const char* CONFIG_PRODUCT_ID;
extern const char* CONFIG_BAUDRATE;
extern const char* CONFIG_INTERFACE;


extern const char* OUTPUT_DISPLAY_WIN;

// only supporting 8 bit pixel depth as of 10 FEB 2013
#define SUPPORTED_PIXEL_DEPTH 8

// the image file name strings
// staging is what gets written to first
// once complete then staging gets mv'd to current to avoid interfering with other programs
extern const char* IMAGE_STAGING_FILE;
extern const char* IMAGE_CURRENT_FILE;
extern const char* IMAGE_CURRENT_PERMS;

// rpi /var/www/pixelpi/image_res/current-image.jpg


// TODO - move this to the config file as it will change
// the COM port in which to expect the serial data
extern const char* DEV_COM_PORT;

// command to signal a new frame from the image device
#define NEW_FRAME_CMD		0x0F


// database related
extern const char* FACEDB_NUM_PERSONS;
extern const char* FACEDB_PERSON_NAME_INDX;
extern const char* FACEDB_NUM_EIGENS;
extern const char* FACEDB_NUM_TRAIN_IMGS;
extern const char* FACEDB_TRAIN_PMAT;
extern const char* FACEDB_EIGEN_VALS;
extern const char* FACEDB_PROJ_TRAIN_IMG;
extern const char* FACEDB_AVG_TRAIN_IMG;
extern const char* FACEDB_EIGEN_VECT_INDX;


// Haar cascade file used for face detection
extern const char* FACE_CASCADE_FILE;

extern const char* FACE_DB_FILE;

extern const char* FACE_TRAINING_FILE;

extern const char* FACE_DATA_DIR;

extern const char* FACE_DATA_DIR_FORMATA;
extern const char* FACE_DATA_DIR_FORMATB;

#define TRAINING_SET_SIZE			25

#define TRAINING_ARRAY_SIZE			200

// default dimensions for faces in the face recognition training set
#define FACE_WIDTH					200
#define FACE_HEIGHT					150

// might get better accuracy after enabling this
//#define USE_MAHALANOBIS_DISTANCE


#endif	/* STD_DEFS_H */

