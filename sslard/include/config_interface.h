/******************************************************
** FILE: config_interface.h
**
** ABSTRACT:
**			This header contains the public
**			configuration interface function declarations.
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

#ifndef CONFIG_INTERFACE_H
#define	CONFIG_INTERFACE_H

// calibration configuration structure
typedef struct
{
	int					image_width;		// number of column pixels to expect from the image device
	int					image_height;		// number of row pixels to expect from the image device
	int					pixel_depth;		// the pixel depth of the image
	// ftdi device parameters
	int					vendor_id;		// the Vendor ID of the ftdi device
	int					product_id;		// the Product ID of the ftdi device
	unsigned int		baudrate;		// device baud rate
	int					interface;		// the device interface channel to use
} _DEVICE_CONFIG;

// TODO - doc new methods

int write_new_train_file( const char* name );

int read_new_train_file( char* name_storage );


/*------------------------------------------------------------------------------
 *	\description		This function reads and loads a calibration configuration
 *						file. The calibration file contains parameters about
 *						the image device and the image settings. See the
 *						_DEVICE_CONFIG structure. If the file does not exist,
 *						the default configuration file is used.
 * 
 *
 *	\param	config:
 *						The _DEVICE_CONFIG structure pointer variable. This
 *						variable should not be null and will fail in that case.
 *						It will be populated by the parameters
 *						in the given configuration file.
 * 
 * 
 *	\param	config_file:
 *						The constant character pointer (cstring) variable. This
 *						variable should contain the absolute file path of the
 *						desired configuration file. If null, the daemon will
 *						log an error message and use the default configuration
 *						file. If the default configuration file does not exist,
 *						the daemon will fail.
 * 
 *	\return int:
 *			CONFIG_PASS - If the execution was successful
 *			CONFIG_FAIL - If the execution failed
 */

int load_device_configuration( _DEVICE_CONFIG* config, const char* config_file );



// TODO - add docs
int load_new_register_values( _DEVICE_CONFIG* config, const char* config_file, char* registers );

#endif	/* CONFIG_INTERFACE_H */

