#########################################################
#########################################################

TARGET  := capture_device_image
SRCS    := src/main.c src/hw_interface.c src/config_interface.c src/image_routines.c
OBJS    := ${SRCS:.c=.o} 
DEPS    := ${SRCS:.c=.dep} 
XDEPS   := $(wildcard ${DEPS}) 

CC	= gcc
CCFLAGS = -std=gnu99 -Wall 
LDFLAGS = 
LIBS    = `pkg-config --cflags --libs opencv` `pkg-config --cflags libconfig` `pkg-config --libs libconfig`
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
	-rm -f *~ *.o ./*.o ${TARGET} 

distclean:: clean
