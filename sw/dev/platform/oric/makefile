# compiler, linker and utilities
CC = gcc
CPP = gcc
LD = gcc
RM = rm
MD = mkdir

CFLAGS = -Wall -g

LDFLAGS = -lalleg

SS_OBJS = \
	ss.o

all:	ss.exe

%.o: %.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(CDEFS) -c $< -o $@

ss.exe: $(SS_OBJS)
	@echo Linking $@...
	$(LD) $(SS_OBJS) $(LDFLAGS) -o $@

clean:
	$(RM) -f $(CLEANFILES)
	@echo Deleting object files...
	$(RM) -f *.o
	@echo Deleting executables...
	$(RM) -f ss.exe
