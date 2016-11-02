# $Id: Makefile,v 1.3 2001/05/03 13:43:42 fma Exp $

TARGET = neokong
FQTN = $(TARGET).bin

#######################################
# Base dir of your m68k gcc toolchain #
#######################################

BASEDIR = $(NEODEV)
AS = as
LD = gcc
CC = gcc
OBJC = objcopy
BIN2O = bin2elf
GFXCC = gfxcc
FIXCNV = fixcnv
CP = cp
MD = mkdir

#######################################
# Path to libraries and include files #
#######################################

INCLUDES = -I include -I include/$(OUTPUT)
INCDIR = $(BASEDIR)/m68k/include
LIBDIR = $(BASEDIR)/m68k/lib
OBJDIR = obj

###################################
# Output: {cart, cd} *lower case* #
###################################
#OUTPUT = cart
#OUTPUT = cd
ifeq ($(OUTPUT),)
	OUTPUT = cart
endif
OUTDIR = output\$(OUTPUT)

############################
# Settings for cart output #
############################
ROMSIZE = 0x20000
PADBYTE = 0x00

##############################
# Object Files and Libraries #
##############################

OBJS = 	$(OBJDIR)/main.o \
				$(OBJDIR)/neogeo.o
				
#LIBS = -linput -lprocess -lmath -lvideo -lc -lgcc

#####################
# Compilation Flags #
#####################

ASFLAGS = -m68000 --register-prefix-optional $(INCLUDES) --defsym __$(OUTPUT)__=1
LDFLAGS = -Wl,-Map=$(TARGET).$(OUTPUT).map,-cref,-Tneo$(OUTPUT).x
CCFLAGS = -m68000 -O3 -Wall -fomit-frame-pointer -ffast-math -fno-builtin -nostartfiles -nodefaultlibs -D__$(OUTPUT)__

ARFLAGS = cr

DEBUG = -g

ifeq ($(OUTPUT),cart)
  DRIVER = puzzledp
  GUID = 202
  P_SIZE = 1024
	PRG = $(GUID)-p1.p1
endif
ifeq ($(OUTPUT),cd)
	PRG = PB_PROG.PRG
endif

##############
# Make rules #
##############

.PHONY : directories

all : directories $(PRG) $(FQTN)
.PHONY : all

directories : $(OBJDIR) $(OUTDIR)

$(OBJDIR) :
	$(MD) $(OBJDIR)

$(OUTDIR) :
	$(MD) $(OUTDIR)

ifeq ($(OUTPUT),cart)

$(PRG): $(FQTN) $(GUID)-c1.c1 $(GUID)-c2.c2 
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

$(FQTN) : $(OBJS) neo$(OUTPUT).x makefile
	$(LD) -L$(LIBDIR) $(CCFLAGS) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

$(OBJDIR)/%.o : %.68k makefile
	$(AS) -a=$*.lst $(ASFLAGS) $< -o $@

ifeq ($(OUTPUT),cart)
install: $(TARGET).$(EXT)
	@copy $(TARGET).$(EXT) $(OUTDIR)\$(DESTNAME)
	@copy $(TARGET).$(EXT) ..\..\MameUI32\roms\puzzledp\$(DESTNAME)
	@copy 202-c1.c1 ..\..\MameUI32\roms\puzzledp
	@copy 202-c2.c2 ..\..\MameUI32\roms\puzzledp
else
install: $(TARGET).$(EXT)
	@copy $(TARGET).$(EXT) $(OUTDIR)\$(DESTNAME)
	@copy PB_CHR.SPR $(OUTDIR)
	rm -f $(TARGET).iso
#	mkisofs -iso-level 1 -graft-points -o $(TARGET).iso -pad -N -V "$(TARGET)" \
#	  $(DESTNAME)=$(OUTDIR)\$(DESTNAME) \
#	  PUZZLE.Z80=$(OUTDIR)\PUZZLE.Z80 \
#	  PB_CHR.SPR=$(OUTDIR)\PB_CHR.SPR \
#	  PB_FIX.FEX=$(OUTDIR)\PB_FIX.FIX \
#	  PUZZLE.PCM=$(OUTDIR)\PUZZLE.PCM \
#	  IPL.TXT=$(OUTDIR)\IPL.TXT \
#	  ABS.TXT=$(OUTDIR)\ABS.TXT \
#	  BIB.TXT=$(OUTDIR)\BIB.TXT \
#	  CPY.TXT=$(OUTDIR)\CPY.TXT
	mkisofs -iso-level 1 -o $(TARGET).iso -pad -N -V "$(TARGET)" $(OUTDIR)
endif

clean:
	rm -f $(OBJDIR)/*.*
	rm -f $(FQTN)
	rm -f $(PRG)
	rm -f roms/$(DRIVER)/$(GUID)-c?.*
	rm -f roms/$(DRIVER)/$(GUID)-p1.p1
	
