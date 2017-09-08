# platform options

#PLATFORM = allegro
#PLATFORM = sdlwin
#PLATFORM = neogeo
#PLATFORM = amigaos
#PLATFORM = genesis

#TARGET = starwars

ifeq (,$(PLATFORM))
	PLATFORM = allegro
endif

ifeq (allegro,$(PLATFORM))
  ifeq (,$(TARGET))
    TARGET = starwars
  endif
else
  TARGET = starwars
endif

# compiler, linker and utilities
AS = as
ifeq ($(PLATFORM),amigaos)
	CC = m68k-amigaos-gcc
	LD = m68k-amigaos-gcc
else
	CC = gcc
	ifeq ($(PLATFORM),genesis)
		LD = ld
		SIZEBND = sizebnd
	else
		LD = gcc
	endif
endif
CPP = g++
ECHO = @echo
RM = rm
MD = mkdir
OBJC = objcopy
MAKEFILE = makefile

# BUILDOPTS
STATIC = 1

ifeq (,$(STATIC))
  STATIC = 0
endif

ifeq ($(PLATFORM),allegro)

  # $(MINGDIR)/setenv.bat

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
	  
  #OSD_INCS = -I $(ALLEGRO)/include
  #OSD_LIBDIR = $(ALLEGRO)/lib
  #OSD_LIBS = -lallegro-4.4.2$(ALLEGRO_MONOLITH)$(ALLEGRO_STATIC)-mt$(ALLEGRO_DEBUG)
  OSD_INCS = -I $(MINGDIR)/include/allegro
  OSD_LIBDIR = $(MINGDIR)/lib
  #OSD_LIBS = -lallegro-4.4.2-md
  OSD_LIBS = -lalleg
  
  OSD_CFLAGS = -Wall -Wno-unused-label -g
  ifeq ($(STATIC),1)
    OSD_LDFLAGS = -lkernel32 -luser32 -lgdi32 -lcomdlg32 -lole32 -ldinput -lddraw -ldxguid -lwinmm -ldsound
  endif
          
endif

ifeq ($(PLATFORM),sdlwin)

  # $(MINGDIR)/setenv.bat

	FQTN = $(TARGET)_$(PLATFORM).exe
	  
  SDL_DIR = $(MINGDIR)/SDL2-2.0.3
  OSD_INCS = -I $(SDL_DIR)/i686-w64-mingw32/include/SDL2
  OSD_LIBDIR = $(SDL_DIR)/i686-w64-mingw32/lib
  OSD_LIBS = -lmingw32 -lSDL2main -lSDL2
  
  OSD_CFLAGS = -Wall -Wno-unused-label -g -w -Wl,-subsystem,console
endif

ifeq ($(PLATFORM),neogeo)

  # $(NEODEV)/setenv.bat
  # mame 
  
  ifeq ($(NEODEV),)
	  NEODEV = /devkit/neodev
  endif

	#OUTPUT = cd
	FQTN = $(TARGET).bin
	
	ifeq ($(OUTPUT),)
		OUTPUT = cart
	endif
	
	ifeq ($(OUTPUT),cart)
	  DRIVER = legendos
	  #GUID = 029
	  #DRIVER = nam1975
	  #GUID = 001
	  DRIVER = pspikes2
	  GUID = 068
	  P_SIZE = 1024
	  #P_SIZE = 512
		PRG = $(GUID)-pg1.p1
	endif
	ifeq ($(OUTPUT),cd)
		PRG = PB_PROG.PRG
	endif
	
	OSD_INCS = -I $(NEODEV)/m68k/include
	OSD_LIBS = $(NEODEV)/m68k/lib
	
	OSD_ASFLAGS = -m68000 --register-prefix-optional --defsym __$(OUTPUT)__=1
	OSD_CFLAGS = -save-temps -m68000 -O3 -Wall -fomit-frame-pointer -ffast-math -fno-builtin
	#OSD_CFLAGS += -Wno-unused-label 
	OSD_CFLAGS += -D__$(OUTPUT)__
	OSD_LDFLAGS = -m68000 -nostartfiles -nodefaultlibs -Wl,-Map=$(TARGET).$(OUTPUT).map,-cref,-Tsrc/osd/$(PLATFORM)/neo$(OUTPUT).x -linput -lvideo -lc -lgcc

	PLATFORM_OBJS = $(OBJDIR)/crt0_$(OUTPUT).o
	
endif

ifeq ($(PLATFORM),amigaos)

  # run cygwin(32) terminal icon
  # run winaue, load congifuration 'mmc'
  
	M68KGCC = /usr/local/amiga
	
	FQTN = $(TARGET)
	
	OSD_INCS = -I $(M68KGCC)/include/g++-3
	OSD_LIBS = $(M68KGCC)/lib/gcc/m68k-amigaos/3.4.0
	
	OSD_CFLAGS =
	OSD_LDFLAGS = -lauto -noixemul
	
endif

ifeq ($(PLATFORM),genesis)

  # $(GDK)/sentenv.bat
  # gens.exe (load rom "kl.bin")
  
	GDK = /devkit/SGDK
	GDK_WIN = \devkit\SGDK

	FQTN = $(TARGET).bin
	
	OSD_INCS = -I $(GDK)/inc -I $(GDK)/res
	OSD_LIBS = $(GDK)/lib

	OSD_CFLAGS = -m68000 -O1 -Wall -Wno-unused-label -fno-builtin -fomit-frame-pointer
	OSD_LDFLAGS = -n -T $(GDK)/md.ld -nostdlib $(OSD_LIBS)/libmd.a $(OSD_LIBS)/libgcc.a

	PLATFORM_OBJS = $(OBJDIR)/sega.o

endif

	ASFLAGS = -I src/osd/$(PLATFORM) $(OSD_ASFLAGS)
	CFLAGS = $(OSD_INCS) -I src/osd/$(PLATFORM) -I src/kl $(OSD_CFLAGS) -D$(PLATFORM)
	LDFLAGS = -L $(OSD_LIBDIR) $(OSD_LIBS) $(OSD_LDFLAGS)

OBJDIR = obj/$(PLATFORM)

STARWARS_OBJS = \
	$(OBJDIR)/starwars.o	\
	$(OBJDIR)/avgrom.o \
	$(OBJDIR)/bitmaps.o

OSD_OBJS = \
	$(OBJDIR)/main.o

ifeq (starwars,$(TARGET))
  OBJS = $(PLATFORM_OBJS) $(STARWARS_OBJS) $(OSD_OBJS)
endif

DEPS = $(OBJS:.o=.d)
	
all: $(OBJDIR) $(PRG) $(FQTN)
.PHONY: all

$(OBJDIR):
	$(MD) -p $(OBJDIR)

out:
	$(MD) -p $@
  
-include $(DEPS)

ifeq ($(OUTPUT),cart)

$(PRG): $(FQTN) $(GUID)-sg1.s1 $(GUID)-c1.c1 $(GUID)-c2.c2 $(GUID)-c3.c3 $(GUID)-c4.c4 $(GUID)-c5.c5 $(GUID)-c6.c6
	$(OBJC) --gap-fill=0x00 --pad-to=0x20000 -R .data -O binary $< $@
	@romwak /f $@ >nul:
	@romwak /p $@ $@ $(P_SIZE) 255 >nul:
	@copy $@ roms\$(DRIVER)

%.s1 : %.bin
	@copy $< roms\$(DRIVER)\$@

%.c1 %.c2 %.c3 %.c4 %.c5 %.c6 : %.bin
	@romwak /p $< $@ 1024 255 > nul:
	@copy $@ roms\$(DRIVER)

else

$(PRG): $(FQTN) PB_CHR.SPR
	$(OBJC) -O binary $< $@
	@copy $@ cds\$(DRIVER)
	@copy PB_CHR.SPR cds\$(DRIVER)
	$(RM) -f $(TARGET).iso
	mkisofs -iso-level 1 -o $(TARGET).iso -pad -N -V "$(TARGET)" cds\$(DRIVER)

endif

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.s $(MAKEFILE)
	$(AS) -ahls=$*.lst $(ASFLAGS) $< -o $@

$(OBJDIR)/%.o: src/starwars/%.c $(MAKEFILE)
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.c $(MAKEFILE)
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(OBJDIR)/%.o: src/osd/$(PLATFORM)/%.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CPP) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $(CDEFS) -Wa,-ahls=$*.lst -c $< -o $@

ifeq ($(PLATFORM),genesis)

$(OBJDIR)/sega.o: $(GDK)/src/boot/sega.s out/rom_head.bin
	$(CC) $(FLAGS) -c $< -o $@

out/rom_head.bin: $(OBJDIR)/rom_head.o
	$(LD) -T $(GDK)/md.ld -nostdlib --oformat binary -o $@ $<

$(OBJDIR)/rom_head.o: $(GDK)/src/boot/rom_head.c
	$(CC) $(CFLAGS) -Wa,-ahls=$*.lst -c $< -o $@

$(FQTN): $(OBJS)
	$(ECHO) Linking $@...
	$(CC) $(OBJS) $(LDFLAGS) -o $(TARGET).out
	$(OBJC) -O binary $(TARGET).out $(FQTN)
	$(SIZEBND) $(FQTN) -sizealign 131072

else

$(FQTN): $(OBJS)
	$(ECHO) Linking $@...
	$(LD) $(OBJS) $(LDFLAGS) -o $@

endif

clean:
	$(ECHO) Deleting object files...
	$(RM) -f $(OBJDIR)/*.o
	$(ECHO) Deleting executables...
	$(RM) -f $(FQTN)
	$(ECHO) Deleting ROMS...
	$(RM) -f $(PRG)
	$(RM) -f $(GUID)-c*.c*
	$(RM) -f $(GUID)-s*.s*
	$(RM) -f roms/$(DRIVER)/$(GUID)-c*.c*
	$(RM) -f roms/$(DRIVER)/$(GUID)-s*.s*
