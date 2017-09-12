# platform options

EXAMPLES = ex1 ex2
TARGET = ex2

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

SDK_OBJS = swsdk.rel cpuvecs.rel

EX_ROMS = $(patsubst %,%.rom,$(EXAMPLES))

all: $(EX_ROMS) $(MAME_ROMS)

$(MAME_ROMS): $(TARGET).rom
	$(CP) $(TARGET).rom roms/starwars/136021.206.1m

%.rom: %.ihx
	$(HEX2BIN) -e rom $<

%.ihx: %.rel $(SDK_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $@ $< $(SDK_OBJS)

%.rel: %.asm $(MAKEFILE)
	$(AS) $(ASFLAGS) $<

clean:
	$(ECHO) Deleting intermediate files...
	$(RM) -f *.rel
	$(RM) -f *.ihx
	$(ECHO) Deleting executables...
	$(RM) -f *.rom
	$(RM) -f $(MAMEROMS)
  