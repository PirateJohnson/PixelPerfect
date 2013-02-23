#########################################################
## FILE: Makefile
##
## ABSTRACT:
##		This Makefile builds and links
##		the sslard program.
##
## DOCUMENTS:
##		See the SDD, SRS, and SD for more information 
##
## AUTHOR:
##		Jonathan Lamb
##		pixel.perfect.asic@gmail.com
##
## CREATION DATE:
##		10 FEB 2013
##
## NOTES:
##
#########################################################

TARGET  := sslard
SRCS    := src/main.c src/daemon_interface.c src/config_interface.c src/image_routines.c src/ftdi_interface.c
OBJS    := ${SRCS:.c=.o} 
DEPS    := ${SRCS:.c=.dep} 
XDEPS   := $(wildcard ${DEPS}) 

CC	= gcc
CCFLAGS = -std=gnu99 -Wall 
LDFLAGS = 
LIBS    = -lftdi -ldaemon `pkg-config --cflags --libs opencv` `pkg-config --cflags libconfig` `pkg-config --libs libconfig`
INCLUDE =

.PHONY: all clean distclean 
all:: ${TARGET} 

ifneq (${XDEPS},) 
include ${XDEPS} 
endif 

${TARGET}: ${OBJS} 
	${CC} ${LDFLAGS} -o $@ $^ ${INCLUDE} ${LIBS} 

${OBJS}: %.o: %.c %.dep 
	${CC} ${CCFLAGS} -o $@ -c $< 

${DEPS}: %.dep: %.c Makefile 
	${CC} ${CCFLAGS} -MM $< > $@ 

clean:: 
	-rm -f ./*~ ./src/*.o ${TARGET} 

distclean:: clean
