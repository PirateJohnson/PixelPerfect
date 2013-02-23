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


// static global data used by the daemon


// the image device configuration structure
// holds the image width, height, and pixel depth
// values obtained through the image-settings.cfg config file
static _DEVICE_CONFIG	dev_config;

// the FTDI image device structure
static _FTDI_DEVICE		ftdi_device;

// the OpenCV image structure
static IplImage*		output_image = NULL;

// the daemon interrupt signal poll timeout
static struct timeval timeout;


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

        // wait for the return value passed from the daemon process - 10 seconds
        if( ( ret = daemon_retval_wait(10) ) < 0 )
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
			
		// open the ftdi device
		if( open_ftdi_device( &ftdi_device, dev_config.vendor_id, dev_config.product_id, dev_config.baudrate, dev_config.interface ) == FTDI_FAIL )
		{
            daemon_retval_send(6);
            goto finish;
		}						
		
        // send OK to parent process
        daemon_retval_send(0);

		daemon_log( LOG_INFO, "%s : %s : successfully started sslard daemon", DAEMON_LOG_PREFIX, LOG_WARN );

        // prepare for select() on the signal fd
        FD_ZERO(&fds);
        fd = daemon_signal_fd();
        FD_SET(fd, &fds);

		// loop until signaled to quit
        while (!quit)
		{
            fd_set fds2 = fds;
			
			// grab device image data
			if( load_ftdi_device_image_data( &ftdi_device, output_image->imageData, output_image->imageSize ) == FTDI_FAIL )
			{
				daemon_log( LOG_INFO, "%s : %s : failed to load FTDI device image data", DAEMON_LOG_PREFIX, LOG_ERROR );
			}	
			
			// save the new image data to the current image file
			if( save_image_to_current( &output_image ) == IMAGE_FAIL )
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
						
						// close the ftdi device
						if( close_ftdi_device( &ftdi_device ) == FTDI_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to close the FTDI device", DAEMON_LOG_PREFIX, LOG_ERROR );
						}
						
						// release the data just allocated
						if( release_image( &output_image ) == IMAGE_FAIL )
						{
							daemon_log( LOG_INFO, "%s : %s : failed to release image data", DAEMON_LOG_PREFIX, LOG_ERROR );
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
		
		opt = getopt( argc, argv, DAEMON_ARG_LIST );
	}
	
	// return value an acceptable argument was found else 0x00
	return ret;
}
