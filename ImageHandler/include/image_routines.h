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
** pixel.perfect.asic@gmail.com
**
** CREATION DATE:
** 10 FEB 2013
**
** NOTES:
**
*******************************************************/

#ifndef IMAGE_ROUTINES_H
#define	IMAGE_ROUTINES_H

int load_new_image( IplImage** image, int width, int height );

int release_image( IplImage** image );

int save_image_to_current( IplImage** image );

int load_image_with_color( IplImage* image, unsigned char color );


#endif	/* IMAGE_ROUTINES_H */

