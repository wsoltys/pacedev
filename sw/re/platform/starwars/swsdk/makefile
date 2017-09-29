# platform options

# list of all examples built by this makefile
EXAMPLES = ex1 ex2 ex3 ex4 ex5 ex6 ex7
# the example to install into MAME
TARGET = ex7

MAME_DIR = roms/starwars
MAME_8000 = 136021.102.1hj
MAME_A000 = 136021.203.1jk
MAME_C000 = 136021.104.1kl
MAME_E000 = 136021.206.1m
MAME_VECROM = 136021-105.1l
MAME_ROMS = $(MAME_8000) $(MAME_A000) $(MAME_E000)

# compiler, linker and utilities
AS = ./as6809
LD = ./aslink
HEX2BIN = ./hex2bin
ECHO = @echo
CP = cp
DD = dd
RM = rm
MD = mkdir
OBJC = objcopy
MAKEFILE = makefile

ASFLAGS = -l -o -s
LDFLAGS = -i -u -m

SDK_OBJS = swsdk.rel cpuvecs.rel
VEC_OBJS = vectrex.rel

EX_ROMS = $(patsubst %,%.rom,$(EXAMPLES)) 

all: $(EX_ROMS) $(MAME_ROMS)

$(MAME_E000): $(TARGET).rom
	$(CP) $(TARGET).rom $(MAME_DIR)/$(MAME_E000)

$(MAME_8000): vectrex_chrset.rom
	$(DD) if=$< of=$@ bs=1 count=8192
	$(CP) $@ $(MAME_DIR)

$(MAME_A000): vectrex_chrset.rom
	$(DD) if=$< of=$@ bs=1 skip=8192
	$(CP) $@ $(MAME_DIR)

%.rom: %.ihx
	$(HEX2BIN) -e rom $<

vectrex_chrset.ihx : vectrex_chrset.rel
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $@ $<

ex7.ihx: ex7.rel $(SDK_OBJS) $(VEC_OBJS)
	$(ECHO) Linking $@...
	$(LD) $(LDFLAGS) $@ $< $(SDK_OBJS) $(VEC_OBJS)

%.ihx: %.rel $(SDK_OBJS) $(VEC_OBJS)
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
  