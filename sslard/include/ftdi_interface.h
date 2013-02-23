/******************************************************
** FILE: ftdi_interface.h
**
** ABSTRACT:
**			This header file contains the public FTDI
**			interface function declarations.
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
**			-Only a single device is currently supported
**
** TODO:
**			Implement read timeouts
**			Support for multiple devices
**
*******************************************************/

#ifndef FTDI_INTERFACE_H
#define	FTDI_INTERFACE_H

#include <ftdi.h>

// the FTDI device parameter structure
typedef struct
{
	struct ftdi_context context;		// the ftdi lib context
	int					vendor_id;		// the Vendor ID of the ftdi device
	int					product_id;		// the Product ID of the ftdi device
	unsigned int		baudrate;		// device baud rate
	int					interface;		// the device interface channel to use
} _FTDI_DEVICE;


/*------------------------------------------------------------------------------
 *	\description		This function opens an FTDI device. The parameters
 *						should be supplied via the configuration structure.
 *						 
 *
 *	\param	ftdi_device:
 *						The _FTDI_DEVICE structure pointer ftdi_device variable.
 *						This variable should not be null and will fail in that
 *						case. It will be populated by the parameters to this
 *						function and will be used to communicate with the device.
 * 
 * 
 *	\param	vendor_id:
 *						The integer Vendor ID variable. See the FTDI device
 *						documentation.
 * 
 *	\param	product_id:
 *						The integer Product ID variable. See the FTDI device
 *						documentation. 
 * 
 *	\param	baudrate:
 *						The unsigned integer Baudrate variable. See the FTDI device
 *						documentation.
 * 
 *	\param	interface:
 *						The integer Interface variable. See the FTDI device
 *						documentation.
 * 
 *	\return int:
 *			FTDI_PASS - If the execution was successful
 *			FTDI_FAIL - If the execution failed
 */

int open_ftdi_device( _FTDI_DEVICE* ftdi_device , int vendor_id, int product_id, unsigned int baudrate, int interface );


/*------------------------------------------------------------------------------
 *	\description		This function closes an FTDI device.
 *						 
 *
 *	\param	ftdi_device:
 *						The _FTDI_DEVICE structure pointer ftdi_device variable.
 *						This variable should not be null and will fail in that
 *						case.
 *  
 *	\return int:
 *			FTDI_PASS - If the execution was successful
 *			FTDI_FAIL - If the execution failed
 */

int close_ftdi_device( _FTDI_DEVICE* ftdi_device );


/*------------------------------------------------------------------------------
 *	\description		This function sends a FRAME_READ command and reads
 *						one frame's worth of data.
 *						 
 *
 *	\param	ftdi_device:
 *						The _FTDI_DEVICE structure pointer ftdi_device variable.
 *						This variable should not be null and will fail in that
 *						case. 
 * 
 * 
 *	\param	image_data:
 *						The character pointer Image Data variable. This variable
 *						should already be allocated to Image Size. This is the
 *						buffer in which the image data gets written to.
 * 
 *	\param	image_size:
 *						The integer Image Size variable. This variable contains
 *						the size of the image data, and will be used in the
 *						FTDI data request. 
 * 
 *	\return int:
 *			FTDI_PASS - If the execution was successful
 *			FTDI_FAIL - If the execution failed
 */

int load_ftdi_device_image_data( _FTDI_DEVICE* ftdi_device, char* image_data, int image_size );

#endif	/* FTDI_INTERFACE_H */

