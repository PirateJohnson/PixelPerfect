/******************************************************
** FILE: hw_interface.h
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
** I am hoping we won't have to implement any comm port timeout checks.
** Right now the timeout is set to 0.5 seconds, this should be more than
** enought time to receive a frame.  
**
*******************************************************/

#ifndef HW_INTERFACE_H
#define	HW_INTERFACE_H

int open_device_comm( int* fd, const char* dev_path );

int close_device_comm( int* fd );

int load_device_image_data( int fd, char* image_data, int image_size, char* send_buff );

// initialize the communication interface attributes
static int init_device_comm_interface( int* fd, int baud, int parity );

// enables/disables the blocking of a read call from the comm port
static int set_blocking (int fd, int should_block);


#endif	/* HW_INTERFACE_H */

