# compiler, linker and utilities
CC = g++
CPP = g++
LD = gcc
RM = rm
MD = mkdir
TARGET = lr
PLATFORM = allegro
MAKEFILE = makefile

#MINGW_VER = 3.4.5
MINGW_VER = 4.5.2
ALLEGRO = /allegro-4.4.2-mingw-$(MINGW_VER)
#ALLEGRO_STATIC = -static
#ALLEGRO_MONOLITH = -monolith
#ALLEGRO_DEBUG = -debug

CFLAGS = -I $(ALLEGRO)/include -I src/osd/$(PLATFORM) -I src/lr -Wall -g

#LDFLAGS = -mwindows -lalleg
LDFLAGS = -L $(ALLEGRO)/lib -lallegro-4.4.2$(ALLEGRO_MONOLITH)$(ALLEGRO_STATIC)-mt$(ALLEGRO_DEBUG)

OBJDIR = obj

LR_OBJS = \
	$(OBJDIR)/lr.o	\
	$(OBJDIR)/title_data_c2bpp.o	\
	$(OBJDIR)/tile_data_c2bpp.o	\
	$(OBJDIR)/level_data.o \
	$(OBJDIR)/debug.o
	
OSD_OBJS = \
	$(OBJDIR)/main.o

OBJS = $(LR_OBJS) $(OSD_OBJS)

DEPS = $(OBJS:.o=.d)
	
all: $(OBJDIR) $(TARGET).exe
.PHONY: all

$(OBJDIR):
	$(MD) -p $(OBJDIR)

-include $(DEPS)

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
	@echo Deleting object files...
	$(RM) -f $(OBJDIR)/*.o
	@echo Deleting executables...
	$(RM) -f $(TARGET).exe
