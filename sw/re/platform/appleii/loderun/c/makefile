# platform options

#PLATFORM = allegro
#PLATFORM = neogeo

ifeq (,$(PLATFORM))
	PLATFORM = allegro
endif

# compiler, linker and utilities
CC = gcc
CPP = g++
LD = gcc
RM = rm
MD = mkdir
TARGET = lr
MAKEFILE = makefile

# BUILDOPTS
STATIC = 1
MONO = 0
GREEN = 1

ifeq (,$(STATIC))
  STATIC = 0
endif

ifeq ($(MONO),1)
	BUILD_OPTS = -DMONO
else
	BUILD_OPTS = -DCOLOUR
endif
ifeq ($(GREEN),1)
	BUILD_OPTS += -DGREEN
endif

ifeq ($(PLATFORM),allegro)
  #MINGW_VER = 3.4.5
  MINGW_VER = 4.5.2
  ifeq ($(STATIC),1)
    ALLEGRO_STATIC = -static
  endif
  ALLEGRO = /allegro-4.4.2-mingw-$(MINGW_VER)
  #ALLEGRO_MONOLITH = -monolith
  #ALLEGRO_DEBUG = -debug
  
  OSD_INCDIR = $(ALLEGRO)/include
  OSD_LIBDIR = $(ALLEGRO)/lib
  OSD_LIBS = -lallegro-4.4.2$(ALLEGRO_MONOLITH)$(ALLEGRO_STATIC)-mt$(ALLEGRO_DEBUG)
  
  OSD_CFLAGS = -Wall -g
  ifeq ($(STATIC),1)
    OSD_LDFLAGS = -lkernel32 -luser32 -lgdi32 -lcomdlg32 -lole32 -ldinput -lddraw -ldxguid -lwinmm -ldsound
  endif
          
endif

ifeq ($(PLATFORM),neogeo)
	NEODEV = 
	OSD_INCDIR = $(NEODEV)/m68k/include
	OSD_LIBS = $(NEODEV)/m68k/lib
	
	OSD_CFLAGS = -m68000 -O3 -Wall -fomit-frame-pointer -ffast-math -fno-builtin -nostartfiles -nodefaultlibs 
	OSD_CFLAGS += -DNO_STDIO -D__cd__
	OSD_LDFLAGS = -m68000 -Wl,-Tsrc/osd/$(PLATFORM)/neocd.x -linput -lvideo -lc -lgcc
endif

CFLAGS = -I $(OSD_INCDIR) -I src/osd/$(PLATFORM) -I src/lr $(OSD_CFLAGS) $(BUILD_OPTS)
LDFLAGS = -L $(OSD_LIBDIR) $(OSD_LIBS) $(OSD_LDFLAGS)

OBJDIR = obj/$(PLATFORM)

LR_OBJS = \
	$(OBJDIR)/lr.o	\
	$(OBJDIR)/title_data_m2bpp.o	\
	$(OBJDIR)/title_data_c2bpp.o	\
	$(OBJDIR)/tile_data_m2bpp.o	\
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

$(OBJDIR)/%.o: src/lr/%.c $(MAKEFILE)
	$(CC) $(CFLAGS) $(CDEFS) -c $< -o $@

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
