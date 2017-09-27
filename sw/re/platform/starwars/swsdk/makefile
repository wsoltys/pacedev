# platform options

# list of all examples built by this makefile
EXAMPLES = ex1 ex2 ex3 ex4 ex5 ex6 ex7
# the example to install into MAME
TARGET = ex7

MAME_DIR = roms/starwars
MAME_ROMS = 136021.206.1m
MAME_VECROM = 136021-105.1l

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

all: $(EX_ROMS) vectrex_vecrom.rom $(MAME_ROMS) $(MAME_VECROM)

$(MAME_ROMS): $(TARGET).rom
	$(CP) $(TARGET).rom $(MAME_DIR)/$(MAME_ROMS)

$(MAME_VECROM): vectrex_vecrom.rom
	$(CP) vectrex_vecrom.rom $(MAME_DIR)/$(MAME_VECROM)

%.rom: %.ihx
	$(HEX2BIN) -e rom $<

vectrex_vecrom.ihx : vectrex_vecrom.rel
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $@ $<

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
  