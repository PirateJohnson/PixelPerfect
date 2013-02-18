/******************************************************
** FILE: config_interface.c
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

#include <stdlib.h>
#include <stdio.h>
#include <libconfig.h>
#include "../include/config_interface.h"
#include "../include/std_defs.h"

// read and load a calibration configuration
int load_device_configuration( _DEVICE_CONFIG* dev_config, const char* config_file )
{
	config_t _config;                               // the libconfig structure
	int tmp_i = 0;									// temp storage
	const char* _file = config_file;                // the config file location
        
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tloading image device configuration file\n", CONFIG_LOG_PREFIX, LOG_DEBUG );
	if( !dev_config )
	{
			printf( "%s\t:\t%s\t:\tfailed to load configuration, device_config pointer is null\n", CONFIG_LOG_PREFIX, LOG_ERROR );
			return CONFIG_FAIL;
	}
#endif
        
	// if the filename was null, use the default configuration file
	if( !_file )
	{
		printf( "%s\t:\t%s\t:\tsupplied config_file parameter is null, using the default config file: %s\n", CONFIG_LOG_PREFIX, LOG_WARN, DEVICE_CONFIG_FILE );
		_file = DEVICE_CONFIG_FILE;
	}

	config_init( &_config );                // init the libconfig structure

	// read the config file, print and return if failed
	if( !config_read_file( &_config, _file ) )
	{
		printf( "%s\t:\t%s\t:\tfailed to read the configuration file: %s\n", CONFIG_LOG_PREFIX, LOG_ERROR, _file );
		// use this to get error details from libconfig if needed
		//printf("\n%s:%d - %s\n", config_error_file(&_config), config_error_line(&_config), config_error_text(&_config));
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
        
	// look up the configuration values
	// image width
	if( !config_lookup_int( &_config, CONFIG_IMAGE_WIDTH, &tmp_i ) )
	{
		printf( "%s\t:\t%s\t:\tfailed to read the configuration parameter: %s\n", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_IMAGE_WIDTH );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->image_width = tmp_i;
	
	tmp_i = 0;
	
	// image height
	if( !config_lookup_int( &_config, CONFIG_IMAGE_HEIGHT, &tmp_i ) )
	{
		printf( "%s\t:\t%s\t:\tfailed to read the configuration parameter: %s\n", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_IMAGE_HEIGHT );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->image_height = tmp_i;
	
	tmp_i = 0;
	
	// pixel depth
	if( !config_lookup_int( &_config, CONFIG_PIXEL_DEPTH, &tmp_i ) )
	{
		printf( "%s\t:\t%s\t:\tfailed to read the configuration parameter: %s\n", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_PIXEL_DEPTH );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->pixel_depth = tmp_i;

	// destroy the libconfig structure
	config_destroy( &_config );
                
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tsuccessfully read device configuration file: %s\n", CONFIG_LOG_PREFIX, LOG_DEBUG, _file );
	printf( "%s\t:\t%s\t:\timage width: %d\n", CONFIG_LOG_PREFIX, LOG_DEBUG, dev_config->image_width );
	printf( "%s\t:\t%s\t:\timage height: %d\n", CONFIG_LOG_PREFIX, LOG_DEBUG, dev_config->image_height );
	printf( "%s\t:\t%s\t:\tpixel depth: %d\n", CONFIG_LOG_PREFIX, LOG_DEBUG, dev_config->pixel_depth );
#endif
                        
	// TODO - more error/sanity checking
	if( dev_config->pixel_depth != SUPPORTED_PIXEL_DEPTH )
	{
		printf( "%s\t:\t%s\t:\tfailed to load device configuration, user pixel depth is not supported - provided: %d -- supported: %d\n", CONFIG_LOG_PREFIX, LOG_ERROR,
				dev_config->pixel_depth, SUPPORTED_PIXEL_DEPTH );
		return CONFIG_FAIL;
	}
	
	return CONFIG_PASS;
}