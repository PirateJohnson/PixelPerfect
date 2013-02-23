/******************************************************
** FILE: image_routines.h
**
** ABSTRACT:
**			This header file contains the public image
**			routine function declarations.
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

#ifndef IMAGE_ROUTINES_H
#define	IMAGE_ROUTINES_H

/*------------------------------------------------------------------------------
 *	\description		This function loads a new OpenCV IplImage given
 *						a width and height. The resources must be released when
 *						no longer in use.
 *						 
 *
 *	\param	image:
 *						The IplImage double pointer Image variable. This should
 *						be an un-initialized parameter, and will get populated
 *						in this function. 
 * 
 *	\param	width:
 *						The integer Width variable. This variable specifies the
 *						width component of the image.
 * 
 *	\param	height:
 *						The integer Height variable. This variable specifies the
 *						height component of the image.
 * 
 *	\return int:
 *			IMAGE_PASS - If the execution was successful
 *			IMAGE_FAIL - If the execution failed
 */

int load_new_image( IplImage** image, int width, int height );


/*------------------------------------------------------------------------------
 *	\description		This function releases an OpenCV IplImage.
 *						 
 *
 *	\param	image:
 *						The IplImage double pointer Image variable. This
 *						variable will be de-allocated and de-referenced.
 * 
 *	\return int:
 *			IMAGE_PASS - If the execution was successful
 *			IMAGE_FAIL - If the execution failed
 */

int release_image( IplImage** image );


/*------------------------------------------------------------------------------
 *	\description		This function saves an OpenCV IplImage to the current
 *						image file. Additionally, the image
 *						lock file mechanism is operated here to provide
 *						a method for mutual exclusion on the current image file.
 *						The image data is written to a staging file, a lock
 *						is placed on the LOCKFILE, the staging file gets renamed,
 *						the permissions get set on the current image file, and
 *						lastly the lock file is removed.
 *
 *	\param	image:
 *						The IplImage double pointer Image variable. This
 *						is the image to be written to file.
 * 
 *	\return int:
 *			IMAGE_PASS - If the execution was successful
 *			IMAGE_FAIL - If the execution failed
 */

int save_image_to_current( IplImage** image );

#endif	/* IMAGE_ROUTINES_H */

