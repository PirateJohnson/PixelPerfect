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
#define DEBUG_PRINT		1

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
#define DAEMON_ARG_LIST		"q"
#define DAEMON_QUIT			'q'
#define DAEMON_PID_FILE		"sslard/sslard"
#define DAEMON_LOG_INDENT	"sslard"
#define DAEMON_IMAGE_LOCKFILE	"/opt/sslard/.lockfile"

// logging strings
#define LOG_ERROR			"ERROR"
#define LOG_DEBUGS			"DEBUG"
#define LOG_WARN			"WARN"
#define LOG_INFOS			"INFO"
#define IMAGE_LOG_PREFIX	"image routines"
#define VISION_LOG_PREFIX	"vision module"
#define FTDI_LOG_PREFIX		"FTDI interface"
#define CONFIG_LOG_PREFIX	"configuration interface"
#define DAEMON_LOG_PREFIX	"daemon interface"

// image device config file
#define DEVICE_CONFIG_FILE	"/opt/sslard/config/image-settings.cfg"

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
#define	IMAGE_STAGING_FILE	"/opt/sslard/staging-image.bmp"
#define	IMAGE_CURRENT_FILE	"/opt/sslard/current-image.bmp"
#define IMAGE_CURRENT_PERMS	"0644"


// the COM port in which to expect the serial data
#define DEV_COM_PORT		"/dev/ttyUSB0"

// command to signal a new frame from the image device
#define NEW_FRAME_CMD		0x0F


// database related
#define FACEDB_NUM_PERSONS			"num_persons"
#define FACEDB_PERSON_NAME_INDX		"person_name_%d"
#define FACEDB_NUM_EIGENS			"num_eigens"
#define FACEDB_NUM_TRAIN_IMGS		"num_train_images"
#define FACEDB_TRAIN_PMAT			"train_person_num_mat"
#define FACEDB_EIGEN_VALS			"eigen_values"
#define FACEDB_PROJ_TRAIN_IMG		"projected_train_face_img"
#define FACEDB_AVG_TRAIN_IMG		"avg_irain_img"
#define FACEDB_EIGEN_VECT_INDX		"eigen_vect_%d"


// Haar cascade file used for face detection
#define FACE_CASCADE_FILE			"res/haarcascade_frontalface_alt.xml"

#define FACE_DB_FILE				"res/facedb.xml"

#define FACE_TRAINING_FILE			"res/train.txt"

#define FACE_DATA_DIR				"data"

#define FACE_DATA_DIR_FORMATA		"data/%d_%s%d.pgm"
#define FACE_DATA_DIR_FORMATB		"%d %s %s\n"

#define TRAINING_SET_SIZE			25

#define TRAINING_ARRAY_SIZE			200

// default dimensions for faces in the face recognition training set
#define FACE_WIDTH					200
#define FACE_HEIGHT					150

// might get better accuracy after enabling this
//#define USE_MAHALANOBIS_DISTANCE


#endif	/* STD_DEFS_H */

