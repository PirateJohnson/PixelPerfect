/******************************************************
** FILE: hw_interface.c
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
** I am hoping we won't have to implement any comm port timeout checks.
** Right now the timeout is set to 0.5 seconds, this should be more than
** enough time to receive a frame.  
**
*******************************************************/

// includes
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>
#include <termios.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include "../include/hw_interface.h"
#include "../include/std_defs.h"

// TODO - error checking *************

int close_device_comm( int* fd )
{
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tclosing the hardware device interface\n", HW_LOG_PREFIX, LOG_DEBUG );
#endif
	
	// close the file descriptor
	close( (*fd) );
	
	(*fd) = 0;
	
	return HW_PASS;
}

int open_device_comm( int* fd, const char* dev_path )
{
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\topening the hardware device interface\n", HW_LOG_PREFIX, LOG_DEBUG );
#endif
	
	// init the comm port
	// 8 data bits
	// 1 stop
	// no parity
	// baud rate: 2,000,000
	// TESTING - need highest possible baud
	// B2000000 - working
	// B115200 - working
	if( init_device_comm_interface( fd, B2000000, 0 ) == HW_FAIL )
		return HW_FAIL;
		
	// enable blocking reads since we always want a full 'packet'
	if( set_blocking( (*fd), 1 ) == HW_FAIL )
		return HW_FAIL;
	
	return HW_PASS;
}

// initialize the communication interface attributes
static int init_device_comm_interface( int* fd, int baud, int parity )
{
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tinitializing device communications\n", HW_LOG_PREFIX, LOG_DEBUG );
#endif
	struct termios tty;
	memset (&tty, 0, sizeof tty);
	
	// open the comm port
	(*fd) = open( DEV_COM_PORT, O_RDWR | O_NOCTTY | O_SYNC );
	
	// check the fd
	if( (*fd) < 0 )
	{
		printf( "%s\t:\t%s\t:\tfailed to open the device comm port, returned: %s\n", HW_LOG_PREFIX, LOG_ERROR, strerror(errno) );
		return HW_FAIL;
	}
	
	// fill the terminal attributes
	if( tcgetattr( (*fd), &tty) != 0 )
	{
		printf( "%s\t:\t%s\t:\tfailed to store the termianl attributes, returned: %d\n", HW_LOG_PREFIX, LOG_ERROR, errno );
		return HW_FAIL;
	}

	// set the output/input baud rate
	cfsetospeed( &tty, baud );
	cfsetispeed( &tty, baud );

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
	// disable IGNBRK for mismatched speed tests; otherwise receive break
	// as \000 chars
	tty.c_iflag &= ~IGNBRK;         // ignore break signal
	tty.c_lflag = 0;                // no signaling chars, no echo,
									// no canonical processing
	tty.c_oflag = 0;                // no remapping, no delays
	tty.c_cc[VMIN]  = 0;            // read doesn't block
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

	tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
									// enable reading
	tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	// set the terminal parameters
	if(  tcsetattr( (*fd), TCSANOW, &tty ) != 0 )
	{
		printf( "%s\t:\t%s\t:\tfailed to set the termianl attributes, returned: %d\n", HW_LOG_PREFIX, LOG_ERROR, errno );
		return HW_FAIL;
	}
	
	return HW_PASS;
}

// enables/disables the blocking of a read call from the comm port
static int set_blocking( int fd, int should_block )
{
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tsetting the read block status to: %d\n", HW_LOG_PREFIX, LOG_DEBUG, should_block );
#endif
	
	struct termios tty;
	memset( &tty, 0, sizeof tty );
	
	if( tcgetattr( fd, &tty) != 0 )
	{
		printf( "%s\t:\t%s\t:\tfailed to store the terminal attributes, returned: %d\n", HW_LOG_PREFIX, LOG_ERROR, errno );
		return HW_FAIL;
	}

	tty.c_cc[VMIN]  = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

	if( tcsetattr (fd, TCSANOW, &tty) != 0 )
	{
		printf( "%s\t:\t%s\t:\tfailed to set the terminal attributes, returned: %d\n", HW_LOG_PREFIX, LOG_ERROR, errno );
		return HW_FAIL;
	}
	
	return SYS_PASS;
}

// TODO - add comments, error checks
// having trouble forcing the 'read' to get all the bytes at once, using a loop structure instead, only getting ~12 bytes per read for some reason
int load_device_image_data( int fd, char* image_data, int image_size, char* send_buff )
{
	int total_read = 0;
	int total_left = image_size;
	int current = 0;
	char* buffer = image_data;
	
#ifdef DEBUG_PRINT
	
	// time variables for calculating latency
	struct timespec t1, t2;
	double dtime = 0.0;
	
	printf( "%s\t:\t%s\t:\tloading device image data\n", HW_LOG_PREFIX, LOG_DEBUG );
#endif	
	
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\tsending out new frame command\n", HW_LOG_PREFIX, LOG_DEBUG );
#endif
		
	// write out the 'send frame' command
	write( fd, send_buff, 1 );
		
	
#ifdef DEBUG_PRINT
	printf( "%s\t:\t%s\t:\treading image data\n", HW_LOG_PREFIX, LOG_DEBUG );
	
	// get the start time
	clock_gettime( CLOCK_MONOTONIC, &t1 );
	
#endif
	
	while( total_left > 0 )
	{
#ifdef DEBUG_PRINT
		printf( "%s\t:\t%s\t:\tbytes read: %d\n", HW_LOG_PREFIX, LOG_DEBUG, total_read );
#endif
		current = read( fd, buffer, total_left );
		
		if( current <= 0 )
		{
			if( current < 0 )
			{
				printf( "%s\t:\t%s\t:\tfailed to read: %d bytes from image device\n", HW_LOG_PREFIX, LOG_ERROR, total_left );
				return HW_FAIL;
			}
			else
				break;
		}
		else
		{
			total_read += current;
			total_left -= current;
			buffer += current;			// so we dont overwrite our data
		}		
	}
		
#ifdef DEBUG_PRINT
	
	// get the end time
	clock_gettime( CLOCK_MONOTONIC, &t2 );
	
	// get the time difference, in seconds
	dtime = (t2.tv_sec - t1.tv_sec) + ((double) (t2.tv_nsec - t1.tv_nsec) / 1e9 );
	
	printf( "%s\t:\t%s\t:\tsuccessfully read image data - received %d bytes - latency: %f (sec)\n", HW_LOG_PREFIX, LOG_DEBUG, total_read, dtime );
#endif
	
	return HW_PASS;
}