/******************************************************
** FILE: image_routines.c
**
** ABSTRACT:
**			This header file contains the public image
**			routine function definitions.
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
**			-See "std_defs.h" for return status, default
**			locations, and default configurations
**
**			-All daemon messages are logged to the syslog,
**			/var/log/syslog
**
*******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <opencv/cv.h>
#include <fcntl.h>
#include <errno.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <libdaemon/dlog.h>
#include "../include/image_routines.h"
#include "../include/std_defs.h"


int load_new_image( IplImage** image , int width, int height )
{
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : loading new OpenCV image - width: %d - height: %d", IMAGE_LOG_PREFIX, LOG_DEBUGS, width, height );
#endif
	
	// create the OpenCV image
	(*image) = cvCreateImage(
			cvSize( width, height ),		// image size
			IPL_DEPTH_8U,													// pixel depth
			1																// channels
			);
	

	return IMAGE_PASS;
}


int release_image( IplImage** image )
{
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : releasing image data", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	// release the OpenCV image data
	cvReleaseImage( image );
	
	// de-reference the pointer
	(*image) = NULL;
	
	return IMAGE_PASS;
}


// save the image to file
int save_image_to_current( IplImage** image )
{
	int ret = 0;
	int lockfd = -1;		// the current image lock file descriptor
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : saving image data to the staging file", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// should have an image by now
	// save to the staging file
	ret = cvSaveImage( IMAGE_STAGING_FILE, (*image), 0 );
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : requesting an exclusive write lock on the current image lock file", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// open the lock file
	// NOTE: this file must exist
	lockfd = open( DAEMON_IMAGE_LOCKFILE, O_RDWR );
	
	// check for failure
	if( lockfd < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, failed to open the lock file: %s - make sure it exist", IMAGE_LOG_PREFIX, LOG_ERROR, DAEMON_IMAGE_LOCKFILE );
		return IMAGE_FAIL;
	}
	
	// make sure the file descriptor pointer is at beginning of file
	lseek( lockfd, 0L, 0 );
	
	// request an exclusive write lock on the current image lock file
	// this blocks until a lock is achieved
	if( lockf( lockfd, F_LOCK, 0) < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, failed to aquire lock on the lock file: %s - error: %s", IMAGE_LOG_PREFIX, LOG_ERROR,
				DAEMON_IMAGE_LOCKFILE, strerror(errno) );
		return IMAGE_FAIL;
	}
	
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : renaming the staging file to current file", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// rename the staging file to current
	ret = rename( IMAGE_STAGING_FILE, IMAGE_CURRENT_FILE );
	
	// check for failure
	if( ret )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, renaming the file returned: %d", IMAGE_LOG_PREFIX, LOG_ERROR, ret );
		return IMAGE_FAIL;
	}
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : changing the permissions of the current image file", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// change the permissions on the image file to 0644
	ret = chmod( IMAGE_CURRENT_FILE, strtol( IMAGE_CURRENT_PERMS, 0, 8 ) );
	
	// check for failure
	if( ret )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, setting permissions on the file returned: %d", IMAGE_LOG_PREFIX, LOG_ERROR, ret );
		return IMAGE_FAIL;
	}
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : releasing the current image lock file", IMAGE_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// make sure the file descriptor pointer is at beginning of file
	lseek( lockfd, 0L, 0 );
	
	// release the lock
	if( lockf( lockfd, F_ULOCK, 0) < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, failed to release the lock file: %s - error: %s", IMAGE_LOG_PREFIX, LOG_ERROR,
				DAEMON_IMAGE_LOCKFILE, strerror(errno) );
		return IMAGE_FAIL;
	}
	
	// close the lock file
	if( close( lockfd ) < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to save image data, failed to close the lock file: %s", IMAGE_LOG_PREFIX, LOG_ERROR, DAEMON_IMAGE_LOCKFILE );
		return IMAGE_FAIL;
	}
	
	return IMAGE_PASS;
}
