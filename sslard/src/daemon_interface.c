/******************************************************
** FILE: daemon_interface.c
**
** ABSTRACT:
**			This source file contains the public daemon
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
*******************************************************/

// includes
#include <stdio.h>
#include <stdlib.h>
#include <opencv/cv.h>
#include <opencv2/core/core_c.h>
#include <opencv2/highgui/highgui_c.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/unistd.h>
#include <sys/select.h>
#include <libdaemon/dfork.h>
#include <libdaemon/dsignal.h>
#include <libdaemon/dlog.h>
#include <libdaemon/dpid.h>
#include <libdaemon/dexec.h>

#include "../include/std_defs.h"
#include "../include/config_interface.h"
#include "../include/image_routines.h"
#include "../include/ftdi_interface.h"
#include "../include/daemon_interface.h"
#include "../include/image_processing.h"


// static global data used by the daemon plus global strings


// the image device configuration structure
// holds the image width, height, and pixel depth
// values obtained through the image-settings.cfg config file
static _DEVICE_CONFIG	dev_config;

// the FTDI image device structure
static _FTDI_DEVICE		ftdi_device;

// the OpenCV image structure
static IplImage*		output_image = NULL;

static _VISION_MODULE	vision_mod;

// TESTING
static _DISPLAY_DEV		display_dev;

static char new_name[256] = { 0 };

// the daemon interrupt signal poll timeout
static struct timeval timeout;


const char* LOG_ERROR	=			"ERROR";
const char* LOG_DEBUGS	=			"DEBUG";
const char* LOG_WARN	=			"WARN";
const char* LOG_INFOS	=			"INFO";
const char* DAEMON_LOG_PREFIX	=	"daemon interface";

const char* IMAGE_LOG_PREFIX	=	"image routines";
const char* VISION_LOG_PREFIX	=	"vision module";
const char* FTDI_LOG_PREFIX		=	"FTDI interface";
const char* CONFIG_LOG_PREFIX	=	"configuration interface";


const char* DAEMON_ARG_LIST		=	"qt:c:";
const char DAEMON_QUIT			=	'q';
const char DAEMON_CMD			=	'c';
const char DAEMON_CMD_UPD		=	'u';
const char DAEMON_TRAIN			=	't';
const char* DAEMON_GUI_MODE		=	"gui";
const char* DAEMON_UPDATE		=	"update";
const char* DAEMON_PID_FILE		=	"sslard/sslard";
const char* DAEMON_LOG_INDENT	=	"sslard";
//const char* DAEMON_IMAGE_LOCKFILE	=	"/opt/sslard/.lockfile";
const char* DAEMON_IMAGE_LOCKFILE	=	"/var/www/pixelpi/sslard/.lockfile";
const char* DAEMON_TRAIN_FILE	=	"/opt/sslard/trainer.txt";


const char* DEVICE_CONFIG_FILE	=	"/opt/sslard/config/image-settings.cfg";
const char* DEVICE_REGISTER_FILE	=	"/opt/sslard/config/register-values.cfg";

const char* CONFIG_IMAGE_WIDTH	=	"IMAGE_WIDTH";
const char* CONFIG_IMAGE_HEIGHT	=	"IMAGE_HEIGHT";
const char* CONFIG_PIXEL_DEPTH	=	"PIXEL_DEPTH";
const char* CONFIG_VENDOR_ID	=	"VENDOR_ID";
const char* CONFIG_PRODUCT_ID	=	"PRODUCT_ID";
const char* CONFIG_BAUDRATE		=	"BAUDRATE";
const char* CONFIG_INTERFACE	=	"INTERFACE";

const char* REG_LOOKUP[] = 
{
	"R0",
	"R1",
	"R2",
	"R3",
	"R4",
	"R5",
	"R6",
	"R7",
	"R8",
	"R9",
	"R10",
	"R11",
	"R12",
	"R13",
	"R14",
	"R15",
	"R16",
	"R17",
	"R18",
	"R19",
	"R20",
	"R22",
	"R22",
	"R23",
	"R24",
};


const char* IMAGE_STAGING_FILE	=	"/var/www/pixelpi/image_res/staging-image.jpg";
//const char* IMAGE_STAGING_FILE	=	"/opt/sslard/staging-image.bmp";
const char* IMAGE_CURRENT_FILE	=	"/var/www/pixelpi/image_res/current-image.jpg";
//const char* IMAGE_CURRENT_FILE	=	"/opt/sslard/current-image.bmp";
const char* IMAGE_CURRENT_PERMS	=	"0644";
const char* OUTPUT_DISPLAY_WIN	=	"Live Feed";


const char* DEV_COM_PORT		=	"/dev/ttyUSB0";


const char* FACEDB_NUM_PERSONS		=	"num_persons";
const char* FACEDB_PERSON_NAME_INDX	=	"person_name_%d";
const char* FACEDB_NUM_EIGENS		=	"num_eigens";
const char* FACEDB_NUM_TRAIN_IMGS	=	"num_train_images";
const char* FACEDB_TRAIN_PMAT		=	"train_person_num_mat";
const char* FACEDB_EIGEN_VALS		=	"eigen_values";
const char* FACEDB_PROJ_TRAIN_IMG	=	"projected_train_face_img";
const char* FACEDB_AVG_TRAIN_IMG	=	"avg_irain_img";
const char* FACEDB_EIGEN_VECT_INDX	=	"eigen_vect_%d";


const char* FACE_CASCADE_FILE		=	"/opt/sslard/res/haarcascade_frontalface_alt.xml";
const char* FACE_DB_FILE			=	"/opt/sslard/res/facedb.xml";
const char* FACE_TRAINING_FILE		=	"/opt/sslard/res/train.txt";
const char* FACE_DATA_DIR			=	"/opt/sslard/data";
const char* FACE_DATA_DIR_FORMATA	=	"/opt/sslard/data/%d_%s%d.pgm";
const char* FACE_DATA_DIR_FORMATB	=	"%d %s %s\n";


// daemon interrupt handlers
static void train_int_handler( int signum );
static void update_int_handler( int signum );


// TODO - remove goto branches after testing


// initialize the daemon interface
int daemonize_init( const char command, int* status )
{
	pid_t pid;
	
#ifdef DEBUG_PRINT
	daemon_log( LOG_INFO, "%s : %s : initializing the daemon interface", DAEMON_LOG_PREFIX, LOG_DEBUGS );
#endif
	
	// check status pointer
	if( !status )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to initialize daemon interface, status pointer is null", DAEMON_LOG_PREFIX, LOG_ERROR );
        return DAEM_FAIL;
	}
	
	(*status) = 0;		// assume success -> status = 0
	
	// set the timeout to 1 microsecond
	timeout.tv_sec = 0;
	timeout.tv_usec = 0;
	
	// TESTING - GUI mode
	if( command == DAEMON_CMD )
	{
		if( run_gui_display() == DAEM_FAIL )
			return DAEM_FAIL;
		else
			return DAEM_PASS;
	}
		
    // reset signal handlers
    if( daemon_reset_sigs(-1) < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to reset all signal handlers: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
        return 1;
    }

    // unblock signals
    if( daemon_unblock_sigs(-1) < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to unblock all signals: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
        return 1;
    }

    // set identification string for the daemon for both syslog and PID file
	daemon_pid_file_ident = DAEMON_PID_FILE;
	daemon_log_ident = DAEMON_LOG_INDENT;

    // check if we are called with QUIT parameter
    if( command == DAEMON_QUIT )
	{
        int ret;

        // kill daemon with SIGTERM

        // check if the new function daemon_pid_file_kill_wait() is available, if it is, use it
        if( ( ret = daemon_pid_file_kill_wait(SIGTERM, 10) ) < 0 )
			daemon_log( LOG_INFO, "%s : %s : failed to kill daemon: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );

        return ret < 0 ? DAEM_FAIL : DAEM_PASS;
    }
	else if( command == DAEMON_TRAIN )
	{
		// else called with a new training name
		
		// signal to read the train file and get the new name
		daemon_log( LOG_INFO, "%s : %s : training new person", DAEMON_LOG_PREFIX, LOG_INFOS );
		//SIGINT
		
		// make sure daemon is running before signal
		pid = daemon_pid_file_is_running();
		
		if( pid >= 0 )
		{
			//  SIGUSR1 will cause the daemon to read the trainer file for the new entry
			kill( pid,  SIGUSR1 );
		}
		
		return DAEM_PASS;
	}
	else if( command == DAEMON_CMD_UPD )
	{
		// else called with an update command
		
		// signal to update the registers
		daemon_log( LOG_INFO, "%s : %s : updating device", DAEMON_LOG_PREFIX, LOG_INFOS );
		//SIGINT
		
		// make sure daemon is running before signal
		pid = daemon_pid_file_is_running();
		
		if( pid >= 0 )
		{
			//  SIGUSR2 will cause the system to update the device
			kill( pid,  SIGUSR2 );
		}
		
		return DAEM_PASS;
	}

    // check that the daemon is not rung twice a the same time
    if( ( pid = daemon_pid_file_is_running() ) >= 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : Daemon already running on PID file %u", DAEMON_LOG_PREFIX, LOG_ERROR, pid );
        return DAEM_FAIL;
    }

    // prepare for return value passing from the initialization procedure of the daemon process
    if( daemon_retval_init() < 0 )
	{
		daemon_log( LOG_INFO, "%s : %s : failed to create pipe", DAEMON_LOG_PREFIX, LOG_ERROR );
        return DAEM_FAIL;
    }

    // do the fork
    if( (pid = daemon_fork()) < 0 )
	{

        // exit on error
        daemon_retval_done();
		
        return DAEM_FAIL;
		
    }
	else if( pid )	// the parent
	{
        int ret;		// return status

        // wait for the return value passed from the daemon process - x seconds
        if( ( ret = daemon_retval_wait(30) ) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : could not receive a return value from daemon process, timed out: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
			(*status) = 255;
            return DAEM_FAIL;
        }

		daemon_log( LOG_INFO, "%s : %s : daemon returned: %i", DAEMON_LOG_PREFIX, ret != 0 ? LOG_ERROR : LOG_WARN, ret );
		(*status) = ret;
        return DAEM_PASS;

    }
	else	// the daemon
	{
        int fd, quit = 0;
        fd_set fds;

        // close FDs
        if( daemon_close_all(-1) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to close all file descriptors: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );

            // send the error condition to the parent process
            daemon_retval_send(1);
			
            goto finish;
        }

        // create the PID file
        if( daemon_pid_file_create() < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to create PID file: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
			
            daemon_retval_send(2);
			
            goto finish;
        }

        // initialize signal handling
        if( daemon_signal_init( SIGINT, SIGTERM, SIGQUIT, SIGHUP, 0 ) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to register signal handlers: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
			
            daemon_retval_send(3);
            
			goto finish;
        }

		// load the configuration structure with values from the config file
		if( load_device_configuration( &dev_config, (const char*) DEVICE_CONFIG_FILE ) == CONFIG_FAIL )
		{
            daemon_retval_send(4);
            goto finish;
        }
		
		// allocate the resources for the new OpenCV image structure
		if( load_new_image( &output_image, dev_config.image_width, dev_config.image_height ) == IMAGE_FAIL )
		{
            daemon_retval_send(5);
            goto finish;
		}
			
		
		// NOTE - this version is for usb webcam only
		/*
		// open the ftdi device		
		if( open_ftdi_device( &ftdi_device, dev_config.vendor_id, dev_config.product_id, dev_config.baudrate, dev_config.interface ) == FTDI_FAIL )
		{
            daemon_retval_send(6);
            goto finish;
		}
		*/
		
		// init the face db, detection, and recognition system
		if( initialize_vision_module( &vision_mod ) == VISION_FAIL )
		{
			daemon_retval_send(7);
            goto finish;
		}
		
		
		// init display/cam dev
		if( init_display_device( &display_dev ) == IMAGE_FAIL )
		{
			daemon_retval_send(8);
            goto finish;
		}		
		
        // send OK to parent process
        daemon_retval_send(0);

		daemon_log( LOG_INFO, "%s : %s : successfully started sslard daemon", DAEMON_LOG_PREFIX, LOG_WARN );

        // prepare for select() on the signal fd
        FD_ZERO(&fds);
        fd = daemon_signal_fd();
        FD_SET(fd, &fds);
		
		// hook up signal handlers
		signal( SIGUSR1, train_int_handler );
		signal( SIGUSR2, update_int_handler );
		
				
		// loop until signaled to quit
        while (!quit)
		{
            fd_set fds2 = fds;
			int found_face = 0;
			int rec_face = 0;
			
			// NOTE - this version is for usb webcam only
			/*
			// if an update has been posted, handle it
			if( ftdi_device.update_registers )
			{
				
				// grab the new register values
				if( load_new_register_values( &dev_config, DEVICE_REGISTER_FILE, ftdi_device.registers ) == CONFIG_FAIL )
				{
					daemon_log( LOG_INFO, "%s : %s : failed to load new register data", DAEMON_LOG_PREFIX, LOG_ERROR );
				}
				
				// update device registers
				if( update_device_registers( &ftdi_device, 1 ) == FTDI_FAIL )
				{
					daemon_log( LOG_INFO, "%s : %s : failed to update FTDI device registers", DAEMON_LOG_PREFIX, LOG_ERROR );
				}
				
				// clear the flag
				ftdi_device.update_registers = 0;
			}
			*/
			
			// NOTE - this version is for usb webcam only
			/*
			// grab device image data
			if( load_ftdi_device_image_data( &ftdi_device, output_image->imageData, output_image->imageSize ) == FTDI_FAIL )
			{
				daemon_log( LOG_INFO, "%s : %s : failed to load FTDI device image data", DAEMON_LOG_PREFIX, LOG_ERROR );
			}
			*/
			
			// grab image data from /dev/video0
			if( get_image_from_display_device( &display_dev, &output_image ) == IMAGE_FAIL )
			{
				daemon_log( LOG_INFO, "%s : %s : failed to get device image data", DAEMON_LOG_PREFIX, LOG_ERROR );
			}
						
			
			if( detect_face( &vision_mod, output_image, &found_face) == VISION_FAIL )
			{
				daemon_log( LOG_INFO, "%s : %s : failed to detect face", DAEMON_LOG_PREFIX, LOG_ERROR );
			}

			
			if( found_face )
			{
				if( recognize_face( &vision_mod, output_image, &rec_face) == VISION_FAIL )
				{
					daemon_log( LOG_INFO, "%s : %s : failed to recognize face", DAEMON_LOG_PREFIX, LOG_ERROR );
				}
			}			
			
			
			// save the new image data to the current image file
			if( save_image_to_current( &vision_mod.processed_face_img ) == IMAGE_FAIL )	
			{
				daemon_log( LOG_INFO, "%s : %s : failed to save device image data", DAEMON_LOG_PREFIX, LOG_ERROR );
			}
			
            // check for an incoming signal
            if( select( FD_SETSIZE, &fds2, 0, 0, &timeout ) < 0 )
			{
                // if we've been interrupted by an incoming signal, continue
                if (errno == EINTR)
                    continue;
				daemon_log( LOG_INFO, "%s : %s : failed to check for incoming signal on select()", DAEMON_LOG_PREFIX, LOG_ERROR );
                break;
            }
			
            // check if a signal has been received
            if( FD_ISSET(fd, &fds2) )
			{				
                int sig;

                // get signal
                if( (sig = daemon_signal_next()) <= 0 )
				{
					daemon_log( LOG_INFO, "%s : %s : failed to get the next signal: %s", DAEMON_LOG_PREFIX, LOG_ERROR, strerror(errno) );
                    break;
                }

                // dispatch signal
                switch( sig )
				{

                    case SIGINT:
                    case SIGQUIT:
                    case SIGTERM:
						daemon_log( LOG_INFO, "%s : %s : got signal: %d", DAEMON_LOG_PREFIX, LOG_WARN, sig );
                        //daemon_log( LOG_WARNING, "Got SIGINT: %d, SIGQUIT: %d or SIGTERM: %d :> %d", SIGINT, SIGQUIT, SIGTERM, sig );						
                        quit = 1;
						
						// NOTE - this version is for usb webcam only
						/*
						// close the ftdi device
						if( close_ftdi_device( &ftdi_device ) == FTDI_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to close the FTDI device", DAEMON_LOG_PREFIX, LOG_ERROR );
						}
						*/
						
						// release the data just allocated
						if( release_image( &output_image ) == IMAGE_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to release image data", DAEMON_LOG_PREFIX, LOG_ERROR );
						}
						
						// release vision module
						if( release_vision_module( &vision_mod ) == VISION_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to release vision module", DAEMON_LOG_PREFIX, LOG_ERROR );
						}
						
						// release display/cam
						if( release_display_device( &display_dev ) == IMAGE_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to release display device", DAEMON_LOG_PREFIX, LOG_ERROR );
						}
						
                        break;

                    case SIGHUP:
						daemon_log( LOG_INFO, "%s : %s : got hang up signal: %d", DAEMON_LOG_PREFIX, LOG_WARN, SIGHUP );
                        break;

                }
            }
        }

        // do a cleanup
finish:
		daemon_log( LOG_INFO, "%s : %s : shutting the daemon down", DAEMON_LOG_PREFIX, LOG_WARN );
        daemon_retval_send( 255 );
        daemon_signal_done();
        daemon_pid_file_remove();
	
		return DAEM_PASS;
	}
}


// parse the command line argument list
char get_arg_command( int argc, char** argv )
{
	// assume no options and no command
	int opt = -1;
	char ret = 0x00;
	
	// disable printing of error messages from getopt
	opterr = 0;
	
	// get the options if any
	opt = getopt( argc, argv, DAEMON_ARG_LIST );
	
	// loop through the argument list
	while( opt != -1 )
	{
		if( opt == DAEMON_QUIT )
		{
			ret = DAEMON_QUIT;
			break;
		}
		else if( (opt == DAEMON_CMD) && (strcmp( DAEMON_GUI_MODE, optarg ) == 0) )
		{
			// run in GUI mode
			ret = DAEMON_CMD;
			break;
		}
		else if( (opt == DAEMON_CMD) && (strcmp( DAEMON_UPDATE, optarg ) == 0) )
		{
			// run an update
			ret = DAEMON_CMD_UPD;
			break;
		}
		else if( (opt == DAEMON_TRAIN) && optarg )
		{
			// train new person
			ret = DAEMON_TRAIN;
			if( write_new_train_file( optarg ) == CONFIG_FAIL )
			{
				// warn
			}						
			break;
		}
		
		opt = getopt( argc, argv, DAEMON_ARG_LIST );
	}
	
	// return value if an acceptable argument was found else 0x00
	return ret;
}


int run_gui_display()
{
	daemon_log( LOG_INFO, "%s : %s : starting the GUI display", DAEMON_LOG_PREFIX, LOG_INFOS );
	
	int lockfd = -1;		// the current image lock file descriptor
	IplImage* image = NULL;
	char esc = '\0';
	
	
	while( esc != DAEMON_QUIT )
	{
		// open the lock file
		// NOTE: this file must exist
		lockfd = open( DAEMON_IMAGE_LOCKFILE, O_RDWR );

		// check for failure
		if( lockfd < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to start GUI display, failed to open the lock file: %s - make sure it exist", IMAGE_LOG_PREFIX, LOG_ERROR, DAEMON_IMAGE_LOCKFILE );
			return IMAGE_FAIL;
		}

		// make sure the file descriptor pointer is at beginning of file
		lseek( lockfd, 0L, 0 );

		// request an exclusive write lock on the current image lock file
		// this blocks until a lock is achieved
		if( lockf( lockfd, F_LOCK, 0) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to start GUI display, failed to aquire lock on the lock file: %s - error: %s", IMAGE_LOG_PREFIX, LOG_ERROR,
					DAEMON_IMAGE_LOCKFILE, strerror(errno) );
			return IMAGE_FAIL;
		}
		
		// critical section
		
		// load the current image
		image = cvLoadImage( IMAGE_CURRENT_FILE, 1 );
		
		// show the image in the window
		cvShowImage( OUTPUT_DISPLAY_WIN, image );

		// let OpenCV process its task
		esc = (char) cvWaitKey(1);
		
		// end critical section
		
		// make sure the file descriptor pointer is at beginning of file
		lseek( lockfd, 0L, 0 );

		// release the lock
		if( lockf( lockfd, F_ULOCK, 0) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to start GUI display, failed to release the lock file: %s - error: %s", IMAGE_LOG_PREFIX, LOG_ERROR,
					DAEMON_IMAGE_LOCKFILE, strerror(errno) );
			return IMAGE_FAIL;
		}

		// close the lock file
		if( close( lockfd ) < 0 )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to start GUI display, failed to close the lock file: %s", IMAGE_LOG_PREFIX, LOG_ERROR, DAEMON_IMAGE_LOCKFILE );
			return IMAGE_FAIL;
		}
		
		
	}	
	
	
	return DAEM_PASS;
}

static void train_int_handler( int signum )
{
	if( signum == SIGUSR1 )
	{
		// new person to train
		if( read_new_train_file( new_name ) == CONFIG_FAIL )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to train: %s to db", DAEMON_LOG_PREFIX, LOG_ERROR, new_name );
			return;
		}
		daemon_log( LOG_INFO, "%s : %s : got signal to train: %s to db", DAEMON_LOG_PREFIX, LOG_INFOS, new_name );
		
		if( enable_training( &vision_mod, new_name ) == VISION_FAIL )
		{
			daemon_log( LOG_INFO, "%s : %s : failed to train: %s to db", DAEMON_LOG_PREFIX, LOG_ERROR, new_name );
		}
	}	
}


static void update_int_handler( int signum )
{
	if( signum == SIGUSR2 )
	{
		// set a flag to update the registers
		ftdi_device.update_registers = 1;
	}
}