# platform options

# list of all examples built by this makefile
EXAMPLES = ex1 ex2 ex3 ex4 ex5
# the example to install into MAME
TARGET = ex4

MAME_DIR = roms/starwars
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
	$(CP) $(TARGET).rom $(MAME_DIR)/$(MAME_ROMS)

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
	$(RM) -f $(MAME_ROMS)
  