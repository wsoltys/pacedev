# compiler, linker and utilities
CC = gcc
CPP = gcc
LD = gcc
RM = rm
MD = mkdir
TARGET = neogeo

CFLAGS = -Wall -g

LDFLAGS = -mwindows -lalleg

NEOGEO_OBJS = \
	neogeo.o

all:	$(TARGET).exe

%.o: %.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(CDEFS) -c $< -o $@

$(TARGET).exe: $(NEOGEO_OBJS)
	@echo Linking $@...
	$(LD) $(NEOGEO_OBJS) my68k.o $(LDFLAGS) -o $@

clean:
	$(RM) -f $(CLEANFILES)
	@echo Deleting object files...
	$(RM) -f neogeo.o
	@echo Deleting executables...
	$(RM) -f $(TARGET).exe
