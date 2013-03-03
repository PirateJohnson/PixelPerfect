/******************************************************
** FILE: image_processing.h
**
** ABSTRACT:
**			This header file contains the public image
**			processing function declarations.
**
** DOCUMENTS:
**			See the SDD, SRS, and SD for more information 
**
** AUTHOR:
**			Jonathan Lamb
**			pixel.perfect.asic@gmail.com
**
** CREATION DATE:
**			23 FEB 2013
**
** NOTES:
**			-See "std_defs.h" for return status, default
**			locations, and default configurations
**
**			-All daemon messages are logged to the syslog,
**			/var/log/syslog
**
*******************************************************/

#ifndef IMAGE_PROCESSING_H
#define	IMAGE_PROCESSING_H


#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/core/types_c.h>
#include <glib-2.0/glib.h>

//
typedef struct
{
	// the cascade file
	CvHaarClassifierCascade*		face_cascade;
	
	// the face rectangle data
	CvRect							face_rect;
	
	// area of interest color - RGB - 0:255
	int								aoi_color[3];
	
	// the person numbers during training
	CvMat*							training_person_nums;
	
	// PCA image subspace
	float*							projected_test_face;
	
	//
	double							face_rec_start_time;
	
	//
	double							face_rec_tally_time;
	
	// the array of face images
	IplImage*						face_image_list[200];

	// the array of person numbers
	CvMat*							person_numbers_img;

	// list of person names
	GList*							person_names;

	// default dimensions for faces in the face recognition training set
	int								t_face_width;
	int								t_face_height;

	// number of people in the training set
	int								num_persons;

	// number of training images
	int								num_train_images;

	// number of eigenvalues
	int								num_eigens;

	// the person value average image
	IplImage*						person_avg_image;

	// the eigenvector image list
	IplImage*						eigenvector_list[200];

	// eigenvalues storage
	CvMat*							eigen_values;

	// projected training faces storage
	CvMat*							projected_train_face_img;
	
	IplImage*						face_img;
	
	IplImage*						sized_img;
	
	IplImage*						equalized_img;
	
	// TODO - use this to convert to color output
	IplImage*						processed_face_img;
	
	// number of new person faces
	int								new_person_faces;
	
	// flag to save next face, will be set when training an image
	int								save_next_face;
	
	// the name of the current training image identity
	const char*						training_name;
} _VISION_MODULE;


// init
int initialize_vision_module( _VISION_MODULE* vmod );


int release_vision_module( _VISION_MODULE* vmod );


// EXPECTS gayscale 8 bit
int detect_face( _VISION_MODULE* vmod, const IplImage* input_image, int* found_face );



int recognize_face( _VISION_MODULE* vmod, const IplImage* input_image, int* recognized_face );



int enable_training( _VISION_MODULE* vmod, const char* name );


// TESTING
IplImage* convert_to_grayscale(const IplImage *imageSrc);

IplImage* get_image_from_cam(void);

IplImage* resize_image(const IplImage *origImg, int newWidth, int newHeight);

#endif	/* IMAGE_PROCESSING_H */

