/******************************************************
** FILE: config_interface.h
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

#ifndef CONFIG_INTERFACE_H
#define	CONFIG_INTERFACE_H

// calibration configuration structure
typedef struct
{
	int		image_width;		// number of column pixels to expect from the image device
	int		image_height;		// number of row pixels to expect from the image device
	int		pixel_depth;		// the pixel depth of the image
} _DEVICE_CONFIG;

// read and load a calibration configuration
int load_device_configuration( _DEVICE_CONFIG* config, const char* config_file );

#endif	/* CONFIG_INTERFACE_H */

