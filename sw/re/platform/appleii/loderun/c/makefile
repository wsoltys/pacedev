# compiler, linker and utilities
CC = g++
CPP = g++
LD = gcc
RM = rm
MD = mkdir
TARGET = lr
PLATFORM = allegro
MAKEFILE = makefile

CFLAGS = -I src/osd/$(PLATFORM) -I src/lr -Wall -g

#LDFLAGS = -mwindows -lalleg
LDFLAGS = -L /data/allegro-4.4.2-mingw-3.4.5/lib -lalleg

OBJDIR = obj

LR_OBJS = \
	$(OBJDIR)/lr.o	\
	$(OBJDIR)/title_data_c2bpp.o	\
	$(OBJDIR)/tile_data_c2bpp.o	\
	$(OBJDIR)/level_data.o
	
OSD_OBJS = \
	$(OBJDIR)/main.o

OBJS = $(LR_OBJS) $(OSD_OBJS)
	
all: $(TARGET).exe

$(OBJDIR)/%.o: src/lr/%.cpp $(MAKEFILE)
	$(CPP) $(CFLAGS) $(CDEFS) -c $< -o $@

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(CDEFS) -c $< -o $@

$(TARGET).exe: $(OBJS)
	@echo Linking $@...
	$(LD) $(OBJS) $(LDFLAGS) -o $@

clean:
	$(RM) -f $(CLEANFILES)
	@echo Deleting object files...
	$(RM) -f $(OBJDIR)/*.o
	@echo Deleting executables...
	$(RM) -f $(TARGET).exe
