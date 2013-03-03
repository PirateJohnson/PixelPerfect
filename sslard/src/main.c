/******************************************************
** FILE: main.c
**
** ABSTRACT:
**			This source file contains the sslard main function.
**			The daemon interface gets called with the
**			command arguments given to the sslard program.  
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
**			-Currently only the '-q' option is supported.
**			This command line argument will terminate the
**			daemon process if one is currently running.
**			Ex:
**			To start:
**				$sslard
**			To stop:
**				$sslard -q
**
**			-See "std_defs.h" for return status, default locations, and default
**			configurations
**			-All daemon messages are logged to the syslog, /var/log/syslog
**
** TODO:
**			Document the working directory /opt/sslard/, /opt/sslard/config,
**			/var/run/sslard/, files /opt/sslard/.lockfile, /var/run/sslard/sslard.pid
** 
*******************************************************/


// includes
#include <stdio.h>
#include <stdlib.h>
#include "../include/std_defs.h"
#include "../include/daemon_interface.h"

// TESTING
#include "../include/image_processing.h"
#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/core/types_c.h>

static _VISION_MODULE test_vis;


/*******************************************************/
/*******************___MAIN___**************************/
/*******************************************************/
int main( int argc, char** argv )
{		
	int daemon_status = 0;
	int i;
	
	// TESTING - disable daemon while testing face rec.
	
	// start the daemon process if not already started or kill the daemon if running
	//if( daemonize_init( get_arg_command( argc, argv ), &daemon_status ) == DAEM_FAIL )
	//	return SYS_FAIL;
	
	// TESTING
	
	//daemon_status = test_hook( argc, argv );
	if( initialize_vision_module( &test_vis ) == VISION_FAIL )
	{
		printf( "init vis failed\n" );
		goto TEST;
	}
	
	
	
	for( i = 0; i < 125; i++ )
	{
		//printf( "\nTESTING - LOOP START\n" );
		IplImage* tmp = NULL;
		IplImage* cam_img = NULL;
		int found_face = 0;
		int rec_face = 0;
		
		// DO NOT RELEASE
		cam_img = get_image_from_cam();
		
		tmp = cam_img;
		
		cam_img = NULL;
		
		cam_img = convert_to_grayscale( tmp );
		
		tmp = NULL;
		
		tmp = cam_img;
		
		cam_img = resize_image( tmp, 200, 150 );
		
		cvReleaseImage( &tmp );
		
		tmp = NULL;
		
		// FACE IMAGE IS NOW SIMULATED INPUT, grey scale and dims
		
		if( i == -35 )
		{
			// TESTING - train
			if( enable_training( &test_vis, "jon" ) == VISION_FAIL )
			{
				printf( "train failed\n" );
				goto TEST;
			}
		}
		
		if( detect_face( &test_vis, cam_img, &found_face) == VISION_FAIL )
		{
			printf( "detect face failed\n" );
			cvReleaseImage( &cam_img );
			goto TEST;
		}
		
		if( found_face )
		{
			if( recognize_face( &test_vis, cam_img, &rec_face) == VISION_FAIL )
			{
				printf( "rec face failed\n" );
				cvReleaseImage( &cam_img );
				goto TEST;
			}
		}
		
		//cvShowImage( "DEBUG OUTPUT", cam_img );
		cvShowImage( "DEBUG OUTPUT", test_vis.processed_face_img );
		
		(void) cvWaitKey(10);
				
		cvReleaseImage( &cam_img );
		
		cam_img = NULL;
		//printf( "\nTESTING - LOOP END\n" );
	}
	
TEST:
	
	if( release_vision_module( &test_vis ) == VISION_FAIL )
	{
		printf( "release vis failed\n" );
		return -1;
	}
	
	return 0;
	
	
	
	return SYS_PASS;
}