# platform options

TARGET = ex1

# compiler, linker and utilities
AS = ./as6809
LD = ./aslink
HEX2BIN = ./hex2bin
ECHO = @echo
CP = copy
RM = rm
MD = mkdir
OBJC = objcopy
MAKEFILE = makefile

ASFLAGS = -l -o -s
LDFLAGS = -i -u -m

OBJS = $(TARGET).rel swsdk.rel

all: $(TARGET).rom

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
	$(RM) -f *.rom
	$(ECHO) Deleting executables...
	$(RM) -f $(TARGET).bin
  