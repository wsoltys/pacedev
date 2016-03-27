# platform options

TARGET = lr

#VARIANT = m1bpp
#VARIANT = m2bpp
VARIANT = c2bpp

#PLATFORM = coco3

ifeq (,$(TARGET))
  TARGET = lr
endif

ifeq (,$(VARIANT))
  VARIANT = c2bpp
endif
  
ifeq (,$(PLATFORM))
	PLATFORM = coco3
endif

# compiler, linker and utilities
AS = as6809
LD = aslink
HEX2BIN = hex2bin
ECHO = @echo
CP = copy
RM = rm
MD = mkdir
OBJC = objcopy
LDR = lrboot
EXE = lr
MAKEFILE = makefile

ifeq ($(PLATFORM),coco3)
  FQLN = $(LDR).bin
  FQEN = $(TARGET)rom.bin
  MEDIA = $(TARGET)_6809.dsk
endif

ASFLAGS = -l -o -s
LDFLAGS = -i

LDR_OBJS = $(LDR).rel

# must be in address order!!!
EXE_OBJS =  tile_data_$(VARIANT).rel \
            title_data_$(VARIANT).rel \
            gameover_data_$(VARIANT).rel \
            $(EXE).rel

all: $(MEDIA)

%.dsk: $(FQLN) $(FQEN)
#	$(CP) $(FQLN) klldr.bin
#	imgtool create coco_jvc_rsdos kl_6809.dsk
#	imgtool put coco_jvc_rsdos kl_6809.dsk klldr.bin $(FQEN)
	$(RM) -f $(MEDIA)
	file2dsk $(MEDIA) $(FQLN) $(FQEN) $(TARGET).bas

# COCO3 BIN format file
$(FQLN): $(LDR_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) -t $<

$(FQEN): $(TARGET).rom
	ldrom -v $(TARGET).rom $(FQEN)
	
%.rom: %.ihx
	$(HEX2BIN) -e rom $(TARGET).ihx

$(TARGET).ihx: $(EXE_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $(TARGET).ihx $(EXE_OBJS)

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(RM) -f *.rom
	$(ECHO) Deleting executables...
	$(RM) -f $(FQLN)
	$(RM) -f $(FQEN)
	$(RM) -f $(MEDIA)
  