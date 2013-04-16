/******************************************************
** FILE: image_processing.c
**
** ABSTRACT:
**			This header file contains the public image
**			processing function definitions.
**
** DOCUMENTS:
**			See the SDD, SRS, and SD for more information 
**
** AUTHOR:
**			Jonathan Lamb
**			pixel.perfect.asic@gmail.com
**
** CREATION DATE:
**			1 MAR 2013
**
** NOTES:
**			-See "std_defs.h" for return status, default
**			locations, and default configurations
**
**			-All daemon messages are logged to the syslog,
**			/var/log/syslog
**
**			Shevin Emami has a lot of information related
**			to these techniques, thanks for the help.
**
*******************************************************/

// TODO - move any variables to config file

// TODO - need to create db file if not exist

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/core/types_c.h>

#include <libdaemon/dlog.h>
#include <glib-2.0/glib.h>
#include <opencv2/legacy/legacy.hpp>
#include "../include/image_processing.h"
#include "../include/std_defs.h"


// static prototypes
static int load_training_data( _VISION_MODULE* vmod );

static int _detect_face( const IplImage* input_image, CvRect* face_rect, const CvHaarClassifierCascade* cascade );

static void delete_node( gpointer data );

static void append_string( GList** list, const char* str );

static int get_nearest_index( _VISION_MODULE* vmod, float * proj_test_face, float *confidence );

static int retrain_online( _VISION_MODULE* vmod );

static int learn_from_file( _VISION_MODULE* vmod, const char *training_file );

static int perform_PCA( _VISION_MODULE* vmod );

static int store_training_data( _VISION_MODULE* vmod );

static int load_face_data_file( _VISION_MODULE* vmod, const char * filename );

static IplImage* crop_to_new_image( const IplImage *img, const CvRect* region );

// init
int initialize_vision_module( _VISION_MODULE* vmod )
{
	int i;
	daemon_log( LOG_INFO, "%s : %s : initializing vision module", VISION_LOG_PREFIX, LOG_INFOS );
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT	
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to initialize vision module, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// clear members
	vmod->training_person_nums = NULL;
	vmod->save_next_face = 0;
	vmod->new_person_faces = 0;
	vmod->person_names = NULL;
	vmod->processed_face_img = NULL;
	vmod->face_img = NULL;
	vmod->projected_test_face = NULL;
	vmod->face_img = NULL;
	vmod->person_avg_image = NULL;
	vmod->equalized_img = NULL;
	vmod->sized_img = NULL;
	
	vmod->training_name = NULL;
	
	// clear the arrays
	for( i = 0; i < TRAINING_ARRAY_SIZE; i++ )
	{
		if( vmod->face_image_list[i] != NULL )
			cvReleaseImage( &vmod->face_image_list[i] );
		
		if( vmod->eigenvector_list[i] != NULL )
			cvReleaseImage( &vmod->eigenvector_list[i] );
	}
	
	
	// set default width and height for faces in the database
	vmod->t_face_width = FACE_WIDTH;
	vmod->t_face_height = FACE_HEIGHT;
	
	// make sure there is a "data" folder, for storing the new person
	// make the folder to be rwx for this user & group but only r-x for others
	mkdir( (const char*) FACE_DATA_DIR, S_IRWXU | S_IRWXG | S_IROTH);
	
	// load the HaarCascade classifier for face detection
	vmod->face_cascade = (CvHaarClassifierCascade*) cvLoad( (const char*) FACE_CASCADE_FILE, 0, 0, 0 );
	
	if( !vmod->face_cascade )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to initialize vision module, failed to load cascade file: %s", VISION_LOG_PREFIX, LOG_ERROR, (const char*) FACE_CASCADE_FILE );
		return VISION_FAIL;
	}	
	
	// load the previously saved training data if any exist
	if( load_training_data( vmod ) == VISION_FAIL )
		return VISION_FAIL;
	else
	{
		// if data exist, set dimensions
		if( vmod->num_train_images > 0 )
		{
			vmod->t_face_width = vmod->person_avg_image->width;
			vmod->t_face_height = vmod->person_avg_image->height;
		}
	}
	
	// project the test images onto the PCA subspace
	// FIX references that should be part of vmod not globals
	if( vmod->num_eigens > 0 )
		vmod->projected_test_face = (float *) cvAlloc( vmod->num_eigens * sizeof(float) );
		
	// get the start time
	vmod->face_rec_start_time = (double) cvGetTickCount();
		
	return VISION_PASS;
}


int release_vision_module( _VISION_MODULE* vmod )
{
	int i;
	daemon_log( LOG_INFO, "%s : %s : releasing vision module", VISION_LOG_PREFIX, LOG_INFOS );
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to release vision module, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// free up and de-reference image pointers
	if( vmod->face_img )
		cvReleaseImage( &vmod->face_img );
	vmod->face_img = NULL;
	
	if( vmod->sized_img )
		cvReleaseImage( &vmod->sized_img );
	vmod->sized_img = NULL;
	
	if( vmod->equalized_img )
		cvReleaseImage( &vmod->equalized_img );
	vmod->equalized_img = NULL;
	
	if( vmod->processed_face_img )
		cvReleaseImage( &vmod->processed_face_img );
	vmod->processed_face_img = NULL;
	
	// NOTE - using cvReleaseImage() fails, using cvFree instead
	if( vmod->person_avg_image )
		cvFree( &vmod->person_avg_image );
	vmod->person_avg_image = NULL;
	
	if( vmod->training_person_nums )
		cvReleaseMat( &vmod->training_person_nums );
	vmod->training_person_nums = NULL;
	
	if( vmod->person_numbers_img )
		cvReleaseMat( &vmod->person_numbers_img );
	vmod->person_numbers_img = NULL;
	
	// release the list of names in the db
	g_list_free_full( vmod->person_names, &delete_node );
	vmod->person_names = NULL;
	
	// release and de-reference cascade file
	cvReleaseHaarClassifierCascade( &vmod->face_cascade );
	vmod->face_cascade = NULL;
	
	// free the projected face data
	cvFree( &vmod->projected_test_face );
	vmod->projected_test_face = NULL;
	
	// free the eigen values matrix
	//cvFree( &vmod->eigen_values );
	if( vmod->eigen_values )
		cvReleaseMat( &vmod->eigen_values );
	vmod->eigen_values = NULL;
	
	// clear the arrays
	for( i = 0; i < TRAINING_ARRAY_SIZE; i++ )
	{
		if( vmod->face_image_list[i] != NULL )
			cvReleaseImage( &vmod->face_image_list[i] );
		
		if( vmod->eigenvector_list[i] != NULL )
			cvReleaseImage( &vmod->eigenvector_list[i] );
	}
	
	// free the cam and memory resources used
	// TESTING
	//cvReleaseCapture( &cam );
				
	return VISION_PASS;
}

// EXPECTS gayscale 8 bit
int detect_face( _VISION_MODULE* vmod, const IplImage* input_image, int* found_face )
{
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : performing face detection", VISION_LOG_PREFIX, LOG_DEBUGS );
	
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face detection, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !input_image )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face detection, input pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !found_face )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face detection, found_face pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// build the output (color) image if needed
	if( vmod->processed_face_img == NULL )
	{
		vmod->processed_face_img = cvCreateImage( cvGetSize( input_image ), IPL_DEPTH_8U, 3 );
	}
	
	// copy the data over, gray to color
	cvCvtColor( input_image, vmod->processed_face_img, CV_GRAY2BGR );
	
	// perform face detection on the input image, using the Haar cascade classifier
	if( _detect_face( input_image, &vmod->face_rect, vmod->face_cascade ) == VISION_FAIL )
		return VISION_FAIL;
	
	// check for face detected
	if( vmod->face_rect.width > 0 )
	{
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : found face", VISION_LOG_PREFIX, LOG_INFOS );
#endif
		(*found_face) = 1;
		
		// draw the detected face region
		cvRectangle( vmod->processed_face_img, cvPoint(vmod->face_rect.x, vmod->face_rect.y),
				cvPoint(vmod->face_rect.x + vmod->face_rect.width-1,
				vmod->face_rect.y + vmod->face_rect.height-1), CV_RGB(0,255,0), 1, 8, 0);
	}
	else
		(*found_face) = 0;
	
	return VISION_PASS;
}


// Returns a new image that is a cropped version of the original image
// MUST FREE
// TODO -  error checking
static IplImage* crop_to_new_image( const IplImage *img, const CvRect* region )
{
	IplImage *tmp_img = NULL;
	IplImage *stage_img = NULL;
	CvSize size;
	size.height = img->height;
	size.width = img->width;

	// create a new grayscale IPL Image and copy contents of img into it
	tmp_img = cvCreateImage(size, IPL_DEPTH_8U, img->nChannels);
	cvCopy(img, tmp_img, NULL);

	// create a new image of the detected region
	// Set region of interest to that surrounding the face
	cvSetImageROI(tmp_img, *region);
	
	// copy region of interest (face) into a new image
	size.width = region->width;
	size.height = region->height;
	stage_img = cvCreateImage(size, IPL_DEPTH_8U, img->nChannels);
	cvCopy(tmp_img, stage_img, NULL);	// copy just the region.

    cvReleaseImage( &tmp_img );
	
	
	// scale the image to the new dimensions, even if the aspect ratio will be changed.
	tmp_img = cvCreateImage( cvSize( FACE_WIDTH, FACE_HEIGHT ), stage_img->depth, stage_img->nChannels );
	
	if( FACE_WIDTH > stage_img->width && FACE_HEIGHT > stage_img->height )
	{
		// make the image larger
		cvResetImageROI( (IplImage*) stage_img );
		cvResize( stage_img, tmp_img, CV_INTER_LINEAR );	// CV_INTER_CUBIC or CV_INTER_LINEAR is good for enlarging
	}
	else
	{
		// make the image smaller
		cvResetImageROI( (IplImage*) stage_img );
		cvResize( stage_img, tmp_img, CV_INTER_AREA );	// CV_INTER_AREA is good for shrinking / decimation, but bad at enlarging.
	}
	
	return tmp_img;		
}

// Find the most likely person based on a detection. Returns the index, and stores the confidence value into confidence.
static int get_nearest_index( _VISION_MODULE* vmod, float * proj_test_face, float *confidence )
{
	double least_dist_sqr = DBL_MAX;
	int i = 0, train_idx = 0, near_idx = 0;

	// for each training image
	for( train_idx = 0; train_idx < vmod->num_train_images; train_idx++ )
	{
		double dist_sqr = 0;

		// for each eigen
		for(i=0; i < vmod->num_eigens; i++)
		{
			float d_i = proj_test_face[i] - vmod->projected_train_face_img->data.fl[train_idx*vmod->num_eigens + i];
			
#ifdef USE_MAHALANOBIS_DISTANCE
			dist_sqr += d_i*d_i / vmod->eigen_values->data.fl[i];  // Mahalanobis distance (might give better results than Eucalidean distance)
#else
			dist_sqr += d_i*d_i; // Euclidean distance.
#endif
		}

		if( dist_sqr < least_dist_sqr )
		{
			least_dist_sqr = dist_sqr;
			near_idx = train_idx;
		}
	}

	// Return the confidence level based on the Euclidean distance,
	// so that similar images should give a confidence between 0.5 to 1.0,
	// and very different images should give a confidence between 0.0 to 0.5.
	(*confidence) = 1.0f - sqrt( least_dist_sqr / (float)(vmod->num_train_images * vmod->num_eigens) ) / 255.0f;

	// return the found index
	return near_idx;
}

int enable_training( _VISION_MODULE* vmod, const char* name )
{	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : enabling training mode - name: %s", VISION_LOG_PREFIX, LOG_DEBUGS, name );
	
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to enable training mode, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !name )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to enable training mode, name pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// set flag to save current images
	vmod->save_next_face = 1;
	
	// set the training name
	vmod->training_name = name;
	
	return VISION_PASS;
}



// name list related
static void delete_node( gpointer data )
{
	g_free( data );
	data = NULL;
}

static void append_string( GList** list, const char* str )
{
	char* tmp = (char*) malloc( sizeof(char) * strlen(str) + 1 );
	strcpy( tmp, str );
	(*list) = g_list_append( (*list), tmp );
	tmp = NULL;	
}

int recognize_face( _VISION_MODULE* vmod, const IplImage* input_image, int* recognized_face )
{
	float confidence = 0.0f;
	int n_index = 0, i_index = 0;
	CvFont font;
	char tmp_buff[256];
	FILE* train_file = NULL;
	int i;
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : performing face recognition", VISION_LOG_PREFIX, LOG_DEBUGS );
	
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face recognition, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !input_image )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face recognition, input_image pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !recognized_face )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face recognition, recognized_face pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}	
#endif
	
	// check to make sure a face was actually detected
	if( vmod->face_rect.width < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform face recognition, no face has been detected in the input image - returning", VISION_LOG_PREFIX, LOG_WARN );
		return VISION_PASS;
	}
	
	// assume we have a valid 8 bit grayscale image with a positive face detected described by the face_rec parameters
	
	// get the detected face image, same dimensions as training set
	vmod->face_img = crop_to_new_image( input_image, &vmod->face_rect );
	
	// Give the image a standard brightness and contrast, in case it was too dark or low contrast
	if( vmod->equalized_img )
		cvReleaseImage( &vmod->equalized_img );
	
	vmod->equalized_img = cvCreateImage( cvGetSize(vmod->face_img), 8, 1 );
	
	cvEqualizeHist( vmod->face_img, vmod->equalized_img );
	
	// if not training and there are entries in the db, try and identify
	if( (!vmod->save_next_face) && (vmod->num_persons > 0) )
	{		
		// project the test image onto the PCA subspace
		cvEigenDecomposite( 
				vmod->equalized_img,
				vmod->num_eigens,
				(IplImage**) vmod->eigenvector_list,
				0, 0,
				vmod->person_avg_image,
				vmod->projected_test_face
				);
		
		// check to see which is the most likely person
		n_index = get_nearest_index( vmod, vmod->projected_test_face, &confidence );
				
		i_index = (int) (vmod->training_person_nums->data.i)[n_index];
#ifdef DEBUG_PRINT
		daemon_log( LOG_INFO, "%s : %s : most likely person in image is: %s -- confidence: %f", VISION_LOG_PREFIX, LOG_INFOS, (char*) g_list_nth_data( vmod->person_names, (i_index-1) ) , confidence );
#endif
		// draw the metrics on the image
	
		cvInitFont( &font,CV_FONT_HERSHEY_PLAIN, 1.0, 1.0, 0,1,CV_AA );
		CvScalar textColor = CV_RGB(0,255,255);	// light blue text
		char text[256];

		snprintf(text, sizeof(text)-1, "name: %s", (char*) g_list_nth_data( vmod->person_names, (i_index-1) ) );

		cvPutText( vmod->processed_face_img, text, cvPoint( vmod->face_rect.x, vmod->face_rect.y + vmod->face_rect.height + 15), &font, textColor);
		snprintf(text, sizeof(text)-1, "confidence: %f", confidence);
		cvPutText( vmod->processed_face_img, text, cvPoint(vmod->face_rect.x, vmod->face_rect.y + vmod->face_rect.height + 30), &font, textColor);
	
	}
	// if training, save the image to the possitive training set for that person
	else if( vmod->save_next_face )
	{
		snprintf( tmp_buff, sizeof(tmp_buff)-1, FACE_DATA_DIR_FORMATA, vmod->num_persons+1, vmod->training_name, vmod->new_person_faces+1 );
		
		daemon_log( LOG_INFO, "%s : %s : storing current face: %s into image %s", VISION_LOG_PREFIX, LOG_INFOS, vmod->training_name, tmp_buff );
		
		cvSaveImage(tmp_buff, vmod->equalized_img, NULL);
		
		vmod->new_person_faces++;
		
		if( vmod->new_person_faces >= (int) TRAINING_SET_SIZE )
		{
			daemon_log( LOG_INFO, "%s : %s : finished training images for: %s -- trained %d images -- storing in: %s", VISION_LOG_PREFIX, LOG_INFOS, (const char*) vmod->training_name,
					(int) TRAINING_SET_SIZE,  (const char*) FACE_TRAINING_FILE );
			
			vmod->save_next_face = 0;
			
			// append the new person to the end of the training data
			train_file = fopen( FACE_TRAINING_FILE, "a");
			
			for( i = 0; i < vmod->new_person_faces; i++)
			{
				snprintf( tmp_buff, sizeof(tmp_buff)-1, FACE_DATA_DIR_FORMATA, vmod->num_persons+1, vmod->training_name, i+1 );
				fprintf( train_file, FACE_DATA_DIR_FORMATB, vmod->num_persons+1, vmod->training_name, tmp_buff );
			}
			
			fclose( train_file );
			
			vmod->new_person_faces = 0;
			
			if( vmod->projected_test_face )
				cvFree( &vmod->projected_test_face );
			
			vmod->projected_test_face = NULL;
			
			vmod->training_name = NULL;
			
			// retrain the db, could take a while...
			
			// free the previous data before getting new data
			if( vmod->training_person_nums )
				cvFree( &vmod->training_person_nums );
			vmod->training_person_nums = NULL;
			
			if( retrain_online( vmod ) == VISION_FAIL )
				return VISION_FAIL;
						
			// project the test images onto the PCA subspace
			
			// free the previous data before getting new data
			if( vmod->projected_test_face )
				cvFree(&vmod->projected_test_face);
			vmod->projected_test_face = NULL;
			
			vmod->projected_test_face = (float *)cvAlloc( vmod->num_eigens * sizeof(float) );
		}
	}	
	else
		daemon_log( LOG_INFO, "%s : %s : failed to perform face recognition, no entries in the database", VISION_LOG_PREFIX, LOG_WARN );
	
	return VISION_PASS;
}

// EXPECTS GRAYSCALE
static int _detect_face( const IplImage* input_image, CvRect* face_rect, const CvHaarClassifierCascade* cascade )
{
	const CvSize min_feature_size = cvSize(20, 20);		// min feature size to search for
	
	const int flags = CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;	// only search for 1 face
	
	const float search_scale_factor = 1.1f;
	IplImage *detect_img;
	CvMemStorage* storage;
	CvRect rc;
	double t;
	CvSeq* rects;
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT	
	if( !input_image )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to detect face in IplImage, input_iamge pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !face_rect )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to detect face in IplImage, face_rec pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !cascade )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to detect face in IplImage, cascade pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// create back-end storage for OpenCV
	storage = cvCreateMemStorage(0);
	
	// TODO - check for failure
	
	// init storage
	cvClearMemStorage( storage );

	// get a reference to the input image
	detect_img = (IplImage*) input_image;	// Assume the input image is to be used.
	
	// set the start time
	t = (double) cvGetTickCount();
	
	// search for a face
	rects = cvHaarDetectObjects( detect_img, (CvHaarClassifierCascade*) cascade, storage,
				search_scale_factor, 3, flags, min_feature_size, cvSize(0,0) );
	// TESTING - added cvSize(0,0) to end, max_size parameter, not sure if 00 will mean any
	
	// get time difference
	t = (double) cvGetTickCount() - t;
	
	// print a message
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : detection latency(ms): %f -- objects found: %d", VISION_LOG_PREFIX, LOG_INFOS,
			t/((double)cvGetTickFrequency()*1000.0), rects->total );
#endif
	
	// get the first detected face (the biggest)
	if( rects->total > 0 )
	{
        rc = *(CvRect*) cvGetSeqElem( rects, 0 );
    }
	else
		rc = cvRect(-1,-1,-1,-1);	// no face

	// copy values
	face_rect->height = rc.height;
	face_rect->width = rc.width;
	face_rect->x = rc.x;
	face_rect->y = rc.y;
	
	// release back-end storage
	cvReleaseMemStorage( &storage );

	// return the biggest face found, in the rect structure, or (-1,-1,-1,-1)

	return VISION_PASS;
}


// TODO - move constants out to defs or config
// NOTE - OpenCV retuns pointers to internal data structures,
//			therefore we must use *copy routines to allocate
//			our system structures, we must never free or
//			reference the OpenCV pointers
static int load_training_data( _VISION_MODULE* vmod )
{
	// storage pointers
	CvMat*	tmp_mat = NULL;
	IplImage*	tmp_img = NULL;
	CvFileStorage* db_file_storage;
	int i;
	
	// check the pointer if debugging
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : loading training data from: %s", VISION_LOG_PREFIX, LOG_DEBUGS, FACE_DB_FILE );
	
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// create a file-storage interface
	// TODO - auto create files/dirs as needed
	db_file_storage = cvOpenFileStorage( (const char*) FACE_DB_FILE, 0, CV_STORAGE_READ, 0 );
	
	// check for failure
	if( !db_file_storage )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to open the database file: %s", VISION_LOG_PREFIX, LOG_ERROR, FACE_DB_FILE );
		return VISION_FAIL;
	}

	// clear the name list	
	g_list_free_full( vmod->person_names, &delete_node );
	vmod->person_names = NULL;
	
		
	// load the names in the db
	vmod->num_persons = cvReadIntByName( db_file_storage, 0, FACEDB_NUM_PERSONS, 0 );
	
	// check if db is empty
	if( vmod->num_persons == 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : no entries found the database file - returning", VISION_LOG_PREFIX, LOG_INFOS );
		
		// release the file-storage interface
		cvReleaseFileStorage( &db_file_storage );
		
		return VISION_PASS;
	}
	
	// else load all the entries
	for( i = 0; i < vmod->num_persons; i++ )
	{
		// get the name and append it to the name list
		char* name_pt;
		char name_buff[256];
		snprintf( name_buff, sizeof(name_buff)-1, FACEDB_PERSON_NAME_INDX, (i+1) );
		name_pt = cvReadStringByName( db_file_storage, 0, name_buff, 0 );
		
		append_string( &vmod->person_names, name_pt );
	}

	// load number of stored eigens
	vmod->num_eigens = cvReadIntByName( db_file_storage, 0, FACEDB_NUM_EIGENS, 0 );
	
	// load number of trained images
	vmod->num_train_images = cvReadIntByName( db_file_storage, 0, FACEDB_NUM_TRAIN_IMGS, 0 );
		
	// look up the training person numbers matrix
	tmp_mat = (CvMat*) cvReadByName( db_file_storage, 0, FACEDB_TRAIN_PMAT, 0 );
	
	// check for failure
	if( tmp_mat == NULL )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to look up training matrix in db", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	else
		vmod->training_person_nums = cvCloneMat( tmp_mat );
	
	// de-reference
	tmp_mat = NULL;
	
	
	
	// lookup eigen values matrix
	tmp_mat = (CvMat*) cvReadByName( db_file_storage, 0, FACEDB_EIGEN_VALS, 0);
	
	// check for failure
	if( tmp_mat == NULL )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to look up eigen matrix in db", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	else
		vmod->eigen_values = cvCloneMat( tmp_mat );
	
	// de-reference
	tmp_mat = NULL;
	
	
	
	// look up the projected training face image matrix
	tmp_mat = (CvMat*) cvReadByName( db_file_storage, 0, FACEDB_PROJ_TRAIN_IMG, 0);
	
	// check for failure
	if( tmp_mat == NULL )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to look up projected training face matrix in db", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	else
		vmod->projected_train_face_img = cvCloneMat( tmp_mat );
	
	// de-reference
	tmp_mat = NULL;
			
	 
	// look up average training image
	tmp_img = (IplImage*) cvReadByName( db_file_storage, 0, FACEDB_AVG_TRAIN_IMG, 0);
	
	// check for failure
	if( tmp_img == NULL )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to look up average training image in db", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	else
		vmod->person_avg_image = cvCloneImage( tmp_img );
	
	// de-reference
	tmp_img = NULL;
	 
	// allocate for the list of eigen images
	//vmod->eigenvector_list = (IplImage**) cvAlloc( num_train_images * sizeof(IplImage*) );

	// get each eigen image
	for( i = 0; i < vmod->num_eigens; i++ )
	{
		char name_buff[200];
		snprintf( name_buff, sizeof(name_buff)-1, FACEDB_EIGEN_VECT_INDX, i );
		
		// load the image
		tmp_img = (IplImage*) cvReadByName( db_file_storage, 0, name_buff, 0);
		
		// check for failure
		if( tmp_img == NULL )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to load training data, failed to look up eigen vector image: %d in db", VISION_LOG_PREFIX, LOG_ERROR, i );
			return VISION_FAIL;
		}
		else
			vmod->eigenvector_list[i] = (IplImage*) cvCloneImage( tmp_img );

		// de-reference
		tmp_img = NULL;
	}

	// release the file-storage interface
	cvReleaseFileStorage( &db_file_storage );

	daemon_log( LOG_INFO, "%s : %s : loaded training data -- number of images: %d -- number of people in db: %d", VISION_LOG_PREFIX, LOG_INFOS,
		vmod->num_train_images, vmod->num_persons );
	
	// print each person loaded
	for( i = 0; i < vmod->num_persons; i++ )
	{
		daemon_log( LOG_INFO, "%s : %s : loaded person: %s", VISION_LOG_PREFIX, LOG_INFOS, (const char*) g_list_nth_data( vmod->person_names, i ) );
	}			
	
	return VISION_PASS;	
}



// Re-train the new face rec database without shutting down.
// Depending on the number of images in the training set and number of people, it might take 30 seconds or so
static int retrain_online( _VISION_MODULE* vmod )
{
	int i;
	daemon_log( LOG_INFO, "%s : %s : retraining database online", VISION_LOG_PREFIX, LOG_INFOS );

	// check the pointer if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to retrain database, vmod pointer is null", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif

	// free & de-reference the face image list
	for( i = 0; i < vmod->num_train_images; i++ )
	{
		if( vmod->face_image_list[i] )
			cvReleaseImage( &vmod->face_image_list[i] );
		vmod->face_image_list[i] = NULL;
	}
	
	// free the array of person numbers
	cvFree( &vmod->person_numbers_img );	
	
	// clear the name list
	g_list_free_full( vmod->person_names, &delete_node );
	vmod->person_names = NULL;
	
	// clear the number of people in the training set
	vmod->num_persons = 0;
	
	// clear the number of training images
	vmod->num_train_images = 0;
	
	// clear the number of eigenvalues
	vmod->num_eigens = 0;
	
	// clear the person avg image
	if( vmod->person_avg_image )
		cvReleaseImage( &vmod->person_avg_image );
	vmod->person_avg_image = NULL;
	
	// for each training image
	for( i = 0; i < vmod->num_train_images; i++ )
	{
		// release and de-reference as needed
		if( vmod->eigenvector_list[i] )
			cvReleaseImage( &vmod->eigenvector_list[i] );
		vmod->eigenvector_list[i] = NULL;
	}
	
	// free the eigen values matrix
	cvFree( &vmod->eigen_values );
	
	// free the projected training image matrix
	cvFree( &vmod->projected_train_face_img );

	daemon_log( LOG_INFO, "%s : %s : retraining database with new person", VISION_LOG_PREFIX, LOG_INFOS );
	
	// retrain from the new data
	if( learn_from_file( vmod, FACE_TRAINING_FILE ) == VISION_FAIL )
		return VISION_FAIL;
	
	// load the previously saved training data
	if( load_training_data( vmod ) == VISION_FAIL )
		return VISION_FAIL;

	return VISION_PASS;
}


// Train from the data in the given text file, and store the trained data into the file
static int learn_from_file( _VISION_MODULE* vmod, const char *training_file )
{
	int i, offset;

	daemon_log( LOG_INFO, "%s : %s : loading training images from: %s", VISION_LOG_PREFIX, LOG_INFOS, training_file );
	
	// check if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training images, vmod pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !training_file )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load training images, training_file pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif

	// load the training data
	if( load_face_data_file( vmod, training_file ) == VISION_FAIL )
		return VISION_FAIL;
	
	daemon_log( LOG_INFO, "%s : %s : number of images loaded: %d", VISION_LOG_PREFIX, LOG_INFOS, vmod->num_train_images);

	// check if enough entries exist
	if( vmod->num_train_images < 2 )
	{
		daemon_log( LOG_INFO, "%s : %s : need at least two entries loaded in order to perform PCA, current: %d - returning", VISION_LOG_PREFIX, LOG_WARN, vmod->num_train_images );
		return VISION_PASS;
	}

	// do PCA on the training faces
	if( perform_PCA( vmod ) == VISION_FAIL )
		return VISION_FAIL;

	// project the training images onto the PCA subspace
	vmod->projected_train_face_img = cvCreateMat( vmod->num_train_images, vmod->num_eigens, CV_32FC1 );
	
	// calc the offset
	offset = vmod->projected_train_face_img->step / sizeof(float);
	
	// for each training image
	for( i = 0; i < vmod->num_train_images; i++ )
	{
		// decompose the eignens
		cvEigenDecomposite(
			vmod->face_image_list[i],
			vmod->num_eigens,
			vmod->eigenvector_list,
			0, 0,
			vmod->person_avg_image,
			vmod->projected_train_face_img->data.fl + i*offset );
	}

	// store the recognition data in the db
	if( store_training_data( vmod ) == VISION_FAIL )
		return VISION_FAIL;
	
	return VISION_PASS;
}

// Do the Principal Component Analysis, finding the average image
// and the eigenfaces that represent any image in the given dataset
// TODO - re-write this
static int perform_PCA( _VISION_MODULE* vmod )
{
	int i;
	CvTermCriteria PCA_calc_limit;
	CvSize img_size;
	
	daemon_log( LOG_INFO, "%s : %s : performing PCA", VISION_LOG_PREFIX, LOG_INFOS );
	
	// check if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to perform PCA, vmod pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif

	// set the number of eigen values to use
	vmod->num_eigens = vmod->num_train_images - 1;

	// allocate the eigenvector images
	img_size.width  = vmod->face_image_list[0]->width;
	img_size.height = vmod->face_image_list[0]->height;
	
	// create the needed eigen images, 32 bit floats
	// NOTE - may be slow on Rpi
	for( i = 0; i < vmod->num_eigens; i++ )
		vmod->eigenvector_list[i] = cvCreateImage(img_size, IPL_DEPTH_32F, 1 );

	// allocate the eigenvalue array matrix
	vmod->eigen_values = cvCreateMat( 1, vmod->num_eigens, CV_32FC1 );

	// allocate the person averaged image
	vmod->person_avg_image = cvCreateImage( img_size, IPL_DEPTH_32F, 1 );

	// set the PCA termination criterion
	PCA_calc_limit = cvTermCriteria( CV_TERMCRIT_ITER, vmod->num_eigens, 1 );

	// compute average image, eigenvalues, and eigenvectors
	cvCalcEigenObjects(
		vmod->num_train_images,
		(void*) vmod->face_image_list,
		(void*) vmod->eigenvector_list,
		//CV_EIGOBJ_NO_CALLBACK,
		0,		// ^^^
		0,
		0,
		&PCA_calc_limit,
		vmod->person_avg_image,
		vmod->eigen_values->data.fl );

	// normalize
	cvNormalize(vmod->eigen_values, vmod->eigen_values, 1, 0, CV_L1, 0);
	
	return VISION_PASS;
}

// Save the training data to the file 'facedata.xml'
// TODO - more error checking
static int store_training_data( _VISION_MODULE* vmod )
{
	CvFileStorage* file_storage = NULL;
	int i;
	
	daemon_log( LOG_INFO, "%s : %s : storing training data to database file: %s", VISION_LOG_PREFIX, LOG_INFOS, FACE_DB_FILE );
	
	// check if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to store training data, vmod pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif

	// create a file-storage interface
	file_storage = cvOpenFileStorage( FACE_DB_FILE, 0, CV_STORAGE_WRITE, 0 );

	// write the number of person loaded
	cvWriteInt( file_storage, FACEDB_NUM_PERSONS, vmod->num_persons );

	// for each person
	for( i = 0; i < vmod->num_persons; i++ )
	{
		char name_buff[256];
		
		// construct a name index string
		snprintf( name_buff, sizeof(name_buff)-1, FACEDB_PERSON_NAME_INDX, (i+1) );
		
		// write the name
		cvWriteString(file_storage, name_buff, g_list_nth_data( vmod->person_names, i ), 0);
	}

	// store all the data
	cvWriteInt( file_storage, FACEDB_NUM_EIGENS, vmod->num_eigens );
	cvWriteInt( file_storage, FACEDB_NUM_TRAIN_IMGS, vmod->num_train_images );
	cvWrite( file_storage, FACEDB_TRAIN_PMAT, vmod->person_numbers_img, cvAttrList(0,0) );
	cvWrite( file_storage, FACEDB_EIGEN_VALS, vmod->eigen_values, cvAttrList(0,0) );
	cvWrite( file_storage, FACEDB_PROJ_TRAIN_IMG, vmod->projected_train_face_img, cvAttrList(0,0) );
	cvWrite( file_storage, FACEDB_AVG_TRAIN_IMG, vmod->person_avg_image, cvAttrList(0,0) );
	
	// for each eigen value
	for( i = 0; i < vmod->num_eigens; i++ )
	{
		char name_buff[200];
		
		// construct a name index string
		snprintf( name_buff, sizeof(name_buff)-1, FACEDB_EIGEN_VECT_INDX, i );
		
		// write out the image
		cvWrite(file_storage, name_buff, vmod->eigenvector_list[i], cvAttrList(0,0));
	}

	// release the file-storage interface
	cvReleaseFileStorage( &file_storage );
	
	return VISION_PASS;
}

// Read the names & image filenames of people from a text file, and load all those images listed
// TODO - more error checking
static int load_face_data_file( _VISION_MODULE* vmod, const char* filename)
{
	FILE* file_handle = NULL;
	char img_file_name[512];
	int face_index = 0, num_faces=0;
	int i;
	
	daemon_log( LOG_INFO, "%s : %s : loading face data file: %s", VISION_LOG_PREFIX, LOG_INFOS, filename );
	
	// check if debugging
#ifdef DEBUG_PRINT
	if( !vmod )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load face data file, vmod pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
	
	if( !filename )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load face data file, filename pointer is NULL", VISION_LOG_PREFIX, LOG_ERROR );
		return VISION_FAIL;
	}
#endif
	
	// open the input file
	if( !(file_handle = fopen(filename, "r")) )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to load face data file, failed to get a file handle on: %s", VISION_LOG_PREFIX, LOG_ERROR, filename );
		return VISION_FAIL;
	}

	// count the number of faces in the file
	while( fgets( img_file_name, sizeof(img_file_name)-1, file_handle ) )
		++num_faces;
	
	// point back to the beginning of the file
	rewind(file_handle);

	// allocate the person numbers matrix
	vmod->person_numbers_img = cvCreateMat( 1, num_faces, CV_32SC1 );
	
	// delete/clear the list of names
	g_list_free_full( vmod->person_names, &delete_node );
	vmod->person_names = NULL;
	
	// clear the number of persons in the db
	vmod->num_persons = 0;

	// store the face images in an array
	for( face_index = 0; face_index < num_faces; face_index++ )
	{
		char name_buffer[256];
		int person_index;

		// read person number (beginning with 1), their name and the image filename.
		fscanf(file_handle, "%d %s %s", &person_index, name_buffer, img_file_name);
				
		// check if a new person is being loaded.
		if( person_index > vmod->num_persons)
		{
			// allocate memory for the extra person (or possibly multiple), using this new person's name.
			for( i = vmod->num_persons; i < person_index; i++ )
			{
				// append to the name list
				append_string( &vmod->person_names, name_buffer );
				
			}
			// set the number of people in the db
			vmod->num_persons = person_index;
		}

		// store the data
		vmod->person_numbers_img->data.i[face_index] = (int) person_index;

		// load the face image from file
		vmod->face_image_list[face_index] = cvLoadImage( img_file_name, CV_LOAD_IMAGE_GRAYSCALE );

		// check for failure
		if( !vmod->face_image_list[face_index] )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to load face data file, failed to image file: %s", VISION_LOG_PREFIX, LOG_ERROR, img_file_name );
			return VISION_FAIL;
		}
	}

	// close the file
	fclose( file_handle );

	daemon_log( LOG_INFO, "%s : %s : loaded face data - images: %d - people: %d", VISION_LOG_PREFIX, LOG_INFOS, num_faces, vmod->num_persons );

	for( i = 0; i < vmod->num_persons; i++ )
	{
		daemon_log( LOG_INFO, "%s : %s : loaded face data for person: %s", VISION_LOG_PREFIX, LOG_INFOS, (char *) g_list_nth_data( vmod->person_names, i ) );
	}

	vmod->num_train_images = num_faces;
	
	return VISION_PASS;
}

