/******************************************************
** FILE: daemon_interface.c
**
** ABSTRACT:
**			This source file contains the public
**			configuration interface function definitions.
**
** DOCUMENTS:
**			See the SDD, SRS, and SD for more information 
**
** AUTHOR:
**			Jonathan Lamb
**			pixel.perfect.asic@gmail.com
**
**			CREATION DATE:
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

#include <stdlib.h>
#include <stdio.h>
#include <libconfig.h>
#include <libdaemon/dlog.h>
#include <string.h>
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
	daemon_log( LOG_INFO, "%s : %s : loading image device configuration file", CONFIG_LOG_PREFIX, LOG_DEBUGS );
	if( !dev_config )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load configuration, device_config pointer is null", CONFIG_LOG_PREFIX, LOG_ERROR );
		return CONFIG_FAIL;
	}
#endif
        
	// if the filename was null, use the default configuration file
	if( !_file )
	{
		daemon_log( LOG_INFO, "%s : %s : supplied config_file parameter is null, using the default config file: %s", CONFIG_LOG_PREFIX, LOG_WARN, DEVICE_CONFIG_FILE );
		_file = DEVICE_CONFIG_FILE;
	}
	
	config_init( &_config );                // init the libconfig structure

	// read the config file, print and return if failed
	if( !config_read_file( &_config, _file ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration file: %s", CONFIG_LOG_PREFIX, LOG_ERROR, _file );
		
		// verbose if debugging
#ifdef DEBUG_PRINT
		// use this to get error details from libconfig if needed
		daemon_log( LOG_INFO, "%s : %s : libconfig returned: %s : %d - %s", CONFIG_LOG_PREFIX, LOG_ERROR, 
				config_error_file(&_config), config_error_line(&_config), config_error_text(&_config) );
#endif
		
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
        
	// look up the configuration values
	
	// image width
	if( !config_lookup_int( &_config, CONFIG_IMAGE_WIDTH, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_IMAGE_WIDTH );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->image_width = tmp_i;
	
	tmp_i = 0;
	
	// image height
	if( !config_lookup_int( &_config, CONFIG_IMAGE_HEIGHT, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_IMAGE_HEIGHT );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->image_height = tmp_i;
	
	tmp_i = 0;
	
	// pixel depth
	if( !config_lookup_int( &_config, CONFIG_PIXEL_DEPTH, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_PIXEL_DEPTH );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->pixel_depth = tmp_i;
	
	tmp_i = 0;
	
	// ftdi vendor id
	if( !config_lookup_int( &_config, CONFIG_VENDOR_ID, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_VENDOR_ID );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->vendor_id = tmp_i;
	
	tmp_i = 0;
	
	// ftdi product id
	if( !config_lookup_int( &_config, CONFIG_PRODUCT_ID, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_PRODUCT_ID );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->product_id = tmp_i;
	
	tmp_i = 0;
	
	// ftdi baudrate
	if( !config_lookup_int( &_config, CONFIG_BAUDRATE, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_BAUDRATE );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->baudrate = (unsigned int) tmp_i;
	
	tmp_i = 0;
	
	// ftdi interface
	if( !config_lookup_int( &_config, CONFIG_INTERFACE, &tmp_i ) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to read the configuration parameter: %s", CONFIG_LOG_PREFIX, LOG_ERROR, CONFIG_INTERFACE );
		config_destroy( &_config );	// destroy the config structure
		return CONFIG_FAIL;
	}
	else		// fill the structure element
		dev_config->interface = tmp_i;
	
	// destroy the libconfig structure
	config_destroy( &_config );
                
	// print all the configuration parameters if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : successfully read device configuration file: %s", CONFIG_LOG_PREFIX, LOG_DEBUGS, _file );
	daemon_log( LOG_INFO, "%s : %s : image width: %d", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->image_width );
	daemon_log( LOG_INFO, "%s : %s : image height: %d", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->image_height );
	daemon_log( LOG_INFO, "%s : %s : pixel depth: %d", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->pixel_depth );
	daemon_log( LOG_INFO, "%s : %s : Vendor ID: %x", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->vendor_id );
	daemon_log( LOG_INFO, "%s : %s : Product ID: %x", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->product_id );
	daemon_log( LOG_INFO, "%s : %s : Baudrate: %u", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->baudrate );
	daemon_log( LOG_INFO, "%s : %s : Interface: %d", CONFIG_LOG_PREFIX, LOG_DEBUGS, dev_config->interface );
#endif
                        
	// make sure the configuration is using a supported pixel depth
	if( dev_config->pixel_depth != SUPPORTED_PIXEL_DEPTH )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load device configuration, user pixel depth is not supported - provided: %d -- supported: %d", CONFIG_LOG_PREFIX, LOG_ERROR,
				dev_config->pixel_depth, SUPPORTED_PIXEL_DEPTH );
		return CONFIG_FAIL;
	}
	
	return CONFIG_PASS;
}


// TODO - error check/msg
int write_new_train_file( const char* name )
{
	//int ret = -1;
	FILE* fp = NULL;
	char tmp[256] = { 0 };
	
	strcpy( tmp, name );
	
	strcat( tmp, "\n" );
	
	fp = fopen( DAEMON_TRAIN_FILE, "w+" );
	
	(void)  fprintf( fp, name );
	
	fclose( fp );
	fp = NULL;
	
	return CONFIG_PASS;
}

int read_new_train_file( char* name_storage )
{
	//int ret = -1;
	FILE* fp = NULL;
	char tmp[256] = { 0 };
	
	fp = fopen( DAEMON_TRAIN_FILE, "r+" );
	
	(void) fgets( tmp, 256, fp );
	
	fclose( fp );
	fp = NULL;
	
	if( strlen( tmp ) > 1 )
	{
		strcpy( name_storage, tmp );
	}
	else
		name_storage[0] = '\0';
	
	return CONFIG_PASS;
}