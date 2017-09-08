# platform options

TARGET = ex1

MAME_ROMS = 136021.206.1m

# compiler, linker and utilities
AS = ./as6809
LD = ./aslink
HEX2BIN = ./hex2bin
ECHO = @echo
CP = cp
RM = rm
MD = mkdir
OBJC = objcopy
MAKEFILE = makefile

ASFLAGS = -l -o -s
LDFLAGS = -i -u -m

OBJS = $(TARGET).rel swsdk.rel cpuvecs.rel

all: $(MAME_ROMS)

$(MAME_ROMS): $(TARGET).rom
	$(CP) $(TARGET).rom roms/starwars/136021.206.1m

%.rom: %.ihx
	$(HEX2BIN) -e rom $<

$(TARGET).ihx: $(OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $@ $(OBJS)

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(ECHO) Deleting executables...
	$(RM) -f $(TARGET).rom
	$(RM) -f $(MAMEROMS)
  