/******************************************************
** FILE: main.c
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


// includes
#include <stdio.h>
#include <stdlib.h>
#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>

#include "../include/std_defs.h"
#include "../include/config_interface.h"
#include "../include/image_routines.h"
#include "../include/hw_interface.h"

/*******************************************************/
/*************___GLOBAL_RESOURCES___********************/
/*******************************************************/

// the image device configuration structure
// holds the image width, height, and pixel depth
// values obtained through the image-settings.cfg config file
static _DEVICE_CONFIG dev_config;

// the comm port file descriptor
static int			comm_fd = 0;

// the OpenCV image structure
static IplImage*	output_image = NULL;


/*******************************************************/
/*******************___MAIN___**************************/
/*******************************************************/
int main( int argc, char** argv )
{
	char tmp_buffer[1] = { NEW_FRAME_CMD };		// temp storage buffer to hold the new frame command, write() expects a buffer
	
	// load the configuration structure with values from the config file
	if( load_device_configuration( &dev_config, DEVICE_CONFIG_FILE ) == CONFIG_FAIL )
		return SYS_FAIL;
	
	// allocate the resources for the new OpenCV image structure
	if( load_new_image( &output_image, dev_config.image_width, dev_config.image_height ) == IMAGE_FAIL )
		return SYS_FAIL;
	
	// open the device comm port
	if( open_device_comm( &comm_fd, DEVICE_CONFIG_FILE ) == HW_FAIL )
		return SYS_FAIL;
	
	// grab device image data
	if( load_device_image_data( comm_fd, output_image->imageData, output_image->imageSize, tmp_buffer ) == HW_FAIL )
		return SYS_FAIL;
	
	// close the device comm port
	if( close_device_comm( &comm_fd ) == HW_FAIL )
		return SYS_FAIL;
	
	// TESTING - load the image with white
	//if( load_image_with_color( output_image, 250 ) == IMAGE_FAIL )
	//	return SYS_FAIL;
	
	// save the new image data to the current image file
	if( save_image_to_current( &output_image ) == IMAGE_FAIL )
		return SYS_FAIL;
	
	if( release_image( &output_image ) == IMAGE_FAIL )
		return SYS_FAIL;
	
	return 0;
}