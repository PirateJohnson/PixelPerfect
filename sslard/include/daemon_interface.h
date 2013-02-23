/******************************************************
** FILE: daemon_interface.h
**
** ABSTRACT:
**			This header file contains the public daemon
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
*******************************************************/

#ifndef DAEMON_INTERFACE_H
#define	DAEMON_INTERFACE_H

/*------------------------------------------------------------------------------
 *	\description		This function initializes the daemon interface. This
 *						includes properly detecting whether or not the daemon
 *						is already running, in which case a warning message
 *						is generated, but not a failure. If the daemon is not
 *						currently running then the daemon will fork() off and
 *						start the image capture process.
 * 
 *
 *	\param	command:
 *						The constant character command to be processed by the
 *						daemon interface. See std_def.h for allowed commands.
 * 
 * 
 *	\param	status:
 *						The integer pointer daemon interface return status
 *						variable. This will contain the return status of
 *						the daemon interface upon return. 
 * 
 *	\return int:
 *			DAEM_PASS - If the execution was successful
 *			DAEM_FAIL - If the execution failed
 */

int daemonize_init( const char command, int* status );



/*------------------------------------------------------------------------------
 *	\description		This function parses the command line argument list.
 *						If it finds a command listed in std_defs.h, the function
 *						will return that command, else it returns 0x00;
 * 
 *
 *	\param	argc:
 *						The integer command line argument count variable.
 *						This variable should contain the number of command
 *						line arguments.
 * 
 * 
 *	\param	argv:
 *						The character double pointer command line argument
 *						vector variable. This variable should contain the
 *						command line arguments.
 * 
 *	\return char:
 *			0x00 - If a command was not found
 *			command - If a command was found, returns the command
 */

char get_arg_command( int argc, char** argv );

#endif	/* DAEMON_INTERFACE_H */

