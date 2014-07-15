# platform options

#PLATFORM = allegro
#PLATFORM = neogeo
#PLATFORM = amigaos
#PLATFORM = genesis

ifeq (,$(PLATFORM))
	PLATFORM = allegro
endif

# compiler, linker and utilities
AS = as
ifneq ($(PLATFORM),amigaos)
	CC = gcc
	LD = gcc
else
	CC = m68k-amigaos-gcc
	LD = m68k-amigaos-gcc
endif
CPP = g++
RM = rm
MD = mkdir
OBJC = objcopy
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
  ifeq ($(ALLEGRO),)
    ALLEGRO = /allegro-4.4.2-mingw-$(MINGW_VER)
  endif
  #ALLEGRO_MONOLITH = -monolith
  #ALLEGRO_DEBUG = -debug

	FQTN = $(TARGET).exe
	  
  OSD_INCDIR = $(ALLEGRO)/include
  OSD_LIBDIR = $(ALLEGRO)/lib
  OSD_LIBS = -lallegro-4.4.2$(ALLEGRO_MONOLITH)$(ALLEGRO_STATIC)-mt$(ALLEGRO_DEBUG)
  
  OSD_CFLAGS = -Wall -g
  ifeq ($(STATIC),1)
    OSD_LDFLAGS = -lkernel32 -luser32 -lgdi32 -lcomdlg32 -lole32 -ldinput -lddraw -ldxguid -lwinmm -ldsound
  endif
          
endif

ifeq ($(PLATFORM),neogeo)

  ifeq ($(NEODEV),)
	  NEODEV = 
  endif

	#OUTPUT = cd
	FQTN = $(TARGET).bin
	
	ifeq ($(OUTPUT),)
		OUTPUT = cart
	endif
	
	ifeq ($(OUTPUT),cart)
		PRG = 202-p1.p1
	endif
	ifeq ($(OUTPUT),cd)
		PRG = PB_PROG.PRG
	endif
	
	OSD_INCDIR = $(NEODEV)/m68k/include
	OSD_LIBS = $(NEODEV)/m68k/lib
	
	OSD_ASFLAGS = -m68000 --register-prefix-optional --defsym __$(OUTPUT)__=1
	OSD_CFLAGS = -m68000 -O3 -Wall -fomit-frame-pointer -ffast-math -fno-builtin
	OSD_CFLAGS += -DNO_STDIO -D__$(OUTPUT)__
	OSD_LDFLAGS = -m68000 -nostartfiles -nodefaultlibs -Wl,-Map=$(TARGET).$(OUTPUT).map,-cref,-Tsrc/osd/$(PLATFORM)/neo$(OUTPUT).x -linput -lvideo -lc -lgcc

	PLATFORM_OBJS = $(OBJDIR)/crt0_$(OUTPUT).o
	
endif

ifeq ($(PLATFORM),amigaos)

	M68KGCC = /usr/local/amiga
	
	FQTN = $(TARGET)
	
	OSD_INCDIR = $(M68KGCC)/include/g++-3
	OSD_LIBS = $(M68KGCC)/lib/gcc/m68k-amigaos/3.4.0
	
	OSD_CFLAGS =
	OSD_LDFLAGS =
	
endif

ifeq ($(PLATFORM),genesis)

	GDK = /SGDK
	GDK_WIN = \SGDK

	FQTN = $(TARGET).bin
	
	OSD_INCDIR = $(GDK)/inc
	OSD_LIBS = $(GDK)/lib

	OSD_CFLAGS = -m68000 -O1 -Wall -fno-builtin -fomit-frame-pointer
	OSD_LDFLAGS = -T $(GDK)/md.ld -nostdlib $(OSD_LIBS)/libmd.a $(OSD_LIBS)/libgcc.a

endif

	ASFLAGS = -I src/osd/$(PLATFORM) $(OSD_ASFLAGS)
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

OBJS = $(PLATFORM_OBJS) $(LR_OBJS) $(OSD_OBJS)

DEPS = $(OBJS:.o=.d)
	
all: $(OBJDIR) $(PRG) $(FQTN)
.PHONY: all

$(OBJDIR):
	$(MD) -p $(OBJDIR)

-include $(DEPS)

ifeq ($(OUTPUT),cart)

$(PRG): $(FQTN) 202-c1.c1 202-c2.c2
	$(OBJC) --gap-fill=0x00 --pad-to=0x20000 -R .data -O binary $< $@
	@romwak /f $@ >nul:
	@romwak /p $@ $@ 1024 255 >nul:
	@copy $@ roms\puzzledp

%.c1 : %.bin
	@romwak /p $< $@ 1024 255 > nul:
	@copy $@ roms\puzzledp

%.c2 : %.bin
	@romwak /p $< $@ 1024 255 > nul:
	@copy $@ roms\puzzledp

else

$(PRG): $(FQTN) PB_CHR.SPR
	$(OBJC) -O binary $< $@
	@copy $@ cds\puzzledp
	@copy PB_CHR.SPR cds\puzzledp
	$(RM) -f $(TARGET).iso
	mkisofs -iso-level 1 -o $(TARGET).iso -pad -N -V "$(TARGET)" cds\puzzledp

endif

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.s $(MAKEFILE)
	$(AS) -ahls=$*.lst $(ASFLAGS) $< -o $@

$(OBJDIR)/%.o: src/lr/%.c $(MAKEFILE)
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.c $(MAKEFILE)
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(FQTN): $(OBJS)
	@echo Linking $@...
	$(LD) $(OBJS) $(LDFLAGS) -o $@

clean:
	@echo Deleting object files...
	$(RM) -f $(OBJDIR)/*.o
	@echo Deleting executables...
	$(RM) -f $(FQTN)
	@echo Deleting ROMS...
	$(RM) -f $(PRG)
	$(RM) -f 202-c*.c*
