/******************************************************
** FILE: ftdi_interface.c
**
** ABSTRACT:
**			This header file contains the public FTDI
**			interface function definitions.
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
** TODO:
**			Implement read timeouts
**			Support for multiple devices
**
*******************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <ftdi.h>
#include <libdaemon/dlog.h>
#include "../include/std_defs.h"
#include "../include/ftdi_interface.h"

// TODO - need a timeout!

// load ftdi device image data from device
int load_ftdi_device_image_data( _FTDI_DEVICE* ftdi_device, char* image_data, int image_size )
{
	int ftdi_ret = 0;		// the ftdi library call return status
	unsigned char cmd_buffer[1] = { NEW_FRAME_CMD };
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	// time variables for calculating latency
	struct timespec t1, t2;
	static double dtime = 0.0;
	int read_count = 0;		// count the number of ftdi_read issued before actually receiving data
	static int frame = 0;
	
	//daemon_log( LOG_INFO, "%s : %s : loading FTDI device image data", FTDI_LOG_PREFIX, LOG_DEBUGS );
	
	if( !ftdi_device )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load device image data, ftdi_device pointer is null", FTDI_LOG_PREFIX, LOG_ERROR );
		return FTDI_FAIL;
	}
	
	if( !image_data )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load device image data, image_data pointer is null", FTDI_LOG_PREFIX, LOG_ERROR );
		return FTDI_FAIL;
	}
	
	//daemon_log( LOG_INFO, "%s : %s : writing FTDI send command", FTDI_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// write the 'send new frame' command
	ftdi_ret = ftdi_write_data( &ftdi_device->context, cmd_buffer, sizeof(cmd_buffer) );
	
#ifdef DEBUG_PRINT
	//daemon_log( LOG_INFO, "%s : %s : waiting for FTDI response", FTDI_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// check for failure
	if( ftdi_ret < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load device image data, libftdi returned this error: %d", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_ret );
		
		// verbose if debugging
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : call: ftdi_write_data: %s", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_get_error_string( &ftdi_device->context ) );
#endif	
		return FTDI_FAIL;
	}
		
	// grab the start time if debugging
#ifdef DEBUG_PRINT
	// get the start time
	clock_gettime( CLOCK_MONOTONIC, &t1 );
#endif

	// read the image data from the device
	// attempt to read until data has been received
	do
	{
#ifdef DEBUG_PRINT
		// increment the read command counter
		read_count++;

		// TESTING
		if( read_count > 300 )
		{
			daemon_log( LOG_INFO, "%s : %s : request for data exceeded 300, timing out", FTDI_LOG_PREFIX, LOG_ERROR );
			return FTDI_FAIL;
		}
#endif
		
		
#ifdef DEBUG_PRINT
		//daemon_log( LOG_INFO, "%s : %s : waiting for FTDI data read: current size: %d", FTDI_LOG_PREFIX, LOG_DEBUGS, ftdi_ret );
#endif

		ftdi_ret = ftdi_read_data( &ftdi_device->context, (unsigned char*) image_data, image_size );
		
			// check for failure
		if( ftdi_ret < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to load device image data, libftdi returned this error: %d", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_ret );

			// verbose if debugging
#ifdef DEBUG_PRINT
			daemon_log( LOG_INFO, "%s : %s : call: ftdi_read_data: %s", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_get_error_string( &ftdi_device->context ) );
#endif	
			return FTDI_FAIL;
		}
		
	} while( ftdi_ret != image_size );
	
	// print metrics if debugging
#ifdef DEBUG_PRINT	
	// get the end time
	clock_gettime( CLOCK_MONOTONIC, &t2 );
	
	frame ++;
	
	// get the time difference, in seconds
	dtime += (t2.tv_sec - t1.tv_sec) + ((double) (t2.tv_nsec - t1.tv_nsec) / 1e9 );
	
	// print metrics every 10 frames
	if( frame == 10 )
	{
		// get the average of 10
		daemon_log( LOG_INFO, "%s : %s : successfully read image data - received %d bytes - latency: %f (sec) - FPS: %f - number of read's: %d",
				FTDI_LOG_PREFIX, LOG_DEBUGS, image_size, (float) (dtime/10), (float) (10/dtime), read_count );
		frame = 0;
		dtime = 0.0;
	}
#endif
	
	return FTDI_PASS;
}

// open an ftdi device
int open_ftdi_device( _FTDI_DEVICE* ftdi_device , int vendor_id, int product_id, unsigned int baudrate, int interface )
{		
	int ftdi_ret = 0;		// the ftdi library call return status
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : opening the FTDI device interface", FTDI_LOG_PREFIX, LOG_DEBUGS );
	
	if( !ftdi_device )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to open device, ftdi_device pointer is null", FTDI_LOG_PREFIX, LOG_ERROR );
		return FTDI_FAIL;
	}
#endif
	
	// assign the structure data
	ftdi_device->vendor_id = vendor_id;
	ftdi_device->product_id = product_id;
	ftdi_device->baudrate = baudrate;
	ftdi_device->interface = interface;
	
	// init the ftdi context
	ftdi_ret = ftdi_init( &ftdi_device->context );
	
	// check for failure
	if( ftdi_ret < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to open device, libftdi failed to allocate its read buffer", FTDI_LOG_PREFIX, LOG_ERROR );
		return FTDI_FAIL;
	}
	
	// set the interface
	ftdi_set_interface( &ftdi_device->context, ftdi_device->interface );
	
	// open the device
	ftdi_ret = ftdi_usb_open( &ftdi_device->context, ftdi_device->vendor_id, ftdi_device->product_id );
	
	// check for failure
	if( ftdi_ret < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to open device, libftdi returned this error: %d", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_ret );
		
		// verbose if debugging
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : call: ftdi_usb_open: %s", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_get_error_string( &ftdi_device->context ) );
#endif		
		return FTDI_FAIL;
	}
	
	// set the baud rate
	ftdi_ret = ftdi_set_baudrate( &ftdi_device->context, ftdi_device->baudrate );
	
	// check for failure
	if( ftdi_ret < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to set device baudrate, libftdi returned this error: %d", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_ret );
		
		// verbose if debugging
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : call: ftdi_set_baudrate: %s", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_get_error_string( &ftdi_device->context ) );
#endif	
		return FTDI_FAIL;
	}
	
	return FTDI_PASS;
}

// close an ftdi device
int close_ftdi_device( _FTDI_DEVICE* ftdi_device )
{
	int ftdi_ret = 0;		// the ftdi library call return status
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : closing the FTDI device interface", FTDI_LOG_PREFIX, LOG_DEBUGS );
	
	if( !ftdi_device )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to close device, ftdi_device pointer is null", FTDI_LOG_PREFIX, LOG_ERROR );
		return FTDI_FAIL;
	}
#endif
	
	// close the device
	ftdi_ret = ftdi_usb_close( &ftdi_device->context );
	
	// check for failure
	if( ftdi_ret < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to close device, libftdi returned this error: %d", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_ret );
		
		// verbose if debugging
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : call: ftdi_usb_close: %s", FTDI_LOG_PREFIX, LOG_ERROR, ftdi_get_error_string( &ftdi_device->context ) );
#endif	
		return FTDI_FAIL;
	}

	// de-init the ftdi device context
	ftdi_deinit( &ftdi_device->context );

	return FTDI_PASS;
}
