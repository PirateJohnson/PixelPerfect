/******************************************************
** FILE: image_routines.c
**
** ABSTRACT:
** 
**
** DOCUMENTS:
** 
**
** AUTHOR:
** Jonathan Lamb
** jonlambusn@gmail.com
**
** CREATION DATE:
** 10 FEB 2013
**
** NOTES:
**
*******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include "../include/image_routines.h"
#include "../include/std_defs.h"

// TODO - error checking

int load_new_image( IplImage** image , int width, int height )
{
#ifdef DEBUG_PRINT
	printf( "%s\t\t:\t%s\t:\tloading new OpenCV image - width: %d - height: %d\n", IMAGE_LOG_PREFIX, LOG_DEBUG, width, height );
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
	printf( "%s\t:\t%s\t:\treleasing image data\n", IMAGE_LOG_PREFIX, LOG_DEBUG );
#endif
	// release the OpenCV image data
	cvReleaseImage( image );
	
	return IMAGE_PASS;
}

int save_image_to_current( IplImage** image )
{
	int ret = 0;
	
#ifdef DEBUG_PRINT
	printf( "%s\t\t:\t%s\t:\tsaving image data to the staging file\n", IMAGE_LOG_PREFIX, LOG_DEBUG );
#endif
	
	// should have an image by now
	// save to the staging file
	ret = cvSaveImage( IMAGE_STAGING_FILE, (*image), 0 );
	
#ifdef DEBUG_PRINT
	printf( "%s\t\t:\t%s\t:\tmoving the staging file to current file\n", IMAGE_LOG_PREFIX, LOG_DEBUG );
#endif
	
	// do a system call to move the staging file to the current image file, will overwrite
	ret = execl( "/bin/mv", "mv", "./" IMAGE_STAGING_FILE, "./" IMAGE_CURRENT_FILE, (char*) 0 );
	
	return IMAGE_PASS;
}

int load_image_with_color( IplImage* image, unsigned char color )
{
#ifdef DEBUG_PRINT
	printf( "%s\t\t:\t%s\t:\tloading image with color: %d\n", IMAGE_LOG_PREFIX, LOG_DEBUG, (int) color );
#endif
	
	int i;
	
	// load each pixel with the color
	for( i = 0; i < image->imageSize; i++ )
	{
		image->imageData[i] = color;
	}
	
	return IMAGE_PASS;
}