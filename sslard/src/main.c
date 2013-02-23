/******************************************************
** FILE: main.c
**
** ABSTRACT:
**			This source file contains the sslard main function.
**			The daemon interface gets called with the
**			command arguments given to the sslard program.  
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
**			-Currently only the '-q' option is supported.
**			This command line argument will terminate the
**			daemon process if one is currently running.
**			Ex:
**			To start:
**				$sslard
**			To stop:
**				$sslard -q
**
**			-See "std_defs.h" for return status, default locations, and default
**			configurations
**			-All daemon messages are logged to the syslog, /var/log/syslog
**
** TODO:
**			Document the working directory /opt/sslard/, /opt/sslard/config,
**			/var/run/sslard/, files /opt/sslard/.lockfile, /var/run/sslard/sslard.pid
** 
*******************************************************/


// includes
#include <stdio.h>
#include <stdlib.h>
#include "../include/std_defs.h"
#include "../include/daemon_interface.h"


/*******************************************************/
/*******************___MAIN___**************************/
/*******************************************************/
int main( int argc, char** argv )
{		
	int daemon_status = 0;
	
	// start the daemon process if not already started or kill the daemon if running
	if( daemonize_init( get_arg_command( argc, argv ), &daemon_status ) == DAEM_FAIL )
		return SYS_FAIL;
	
	return SYS_PASS;
}