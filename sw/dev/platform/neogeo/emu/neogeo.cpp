#include <stdio.h>
#include <stdlib.h>

#include "starcpu.h"

/*
 *  "Starscream 680x0 emulation library by Neill Corlett (corlett@elwha.nrrc.ncsu.edu)"
 */

static unsigned char *vectors;          // $000000-$00007F (128 bytes)
static unsigned char *rom_bank_1;       // $000000-$0FFFFF (1MB) - overlaps above!
static unsigned char *ram_bank;         // $100000-$10FFFF (64kB)
static unsigned char *rom_bank_2;       // $200000-$2FFFFF (1MB)
static unsigned char *palette_ram;      // $400000-$401FFF (8kB)
static unsigned char *memcard_ram;      // $800000-$800FFF (4kB)
static unsigned char *system_bios;      // $C00000-$C1FFFF (128kB)
static unsigned char *battery_sram;     // $D00000-$D0FFFF (64kB)

// System control register $3A0000-$3A001F
// - $3A000X (odd) = reset
// - $3A001X (odd) = set
static unsigned char sc[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

struct STARSCREAM_PROGRAMREGION neogeo_programfetch[] = 
{
  { 0x000000, 0x00007F, (unsigned)vectors - 0x000000 },
  { 0x000000, 0x0FFFFF, (unsigned)rom_bank_1 - 0x000000 },    // overlapping!
  { 0x100000, 0x10FFFF, (unsigned)ram_bank - 0x100000 },
  { 0x200000, 0x2FFFEF, (unsigned)rom_bank_2 - 0x200000 },
  { 0xC00000, 0xC1FFFF, (unsigned)system_bios - 0xC00000 },
  { (unsigned int)-1, (unsigned int)-1, 0 }
};

struct STARSCREAM_DATAREGION neogeo_readbyte[] = 
{
  { 0x000000, 0x00007F, NULL, vectors },
  { 0x000000, 0x0FFFFF, NULL, rom_bank_1 },   // overlapping
  { 0x100000, 0x10FFFF, NULL, ram_bank },
  { 0x200000, 0x2FFFFF, NULL, rom_bank_2 },
  //{ 0x300000, 0x3FFFFF, read_300000, 0 },
  { 0x400000, 0x401FFF, NULL, palette_ram },
  { 0x800000, 0x800FFF, NULL, memcard_ram },
  { 0xC00000, 0xC1FFFF, NULL, system_bios },
  { 0xD00000, 0xD0FFFF, NULL, battery_sram },
  { (unsigned int)-1, (unsigned int)-1, NULL }
};

struct STARSCREAM_DATAREGION *neogeo_readword = neogeo_readbyte;

struct STARSCREAM_DATAREGION neogeo_writebyte[] = 
{
  { 0x100000, 0x10FFFF, NULL, ram_bank },
  //{ 0x300000, 0x3FFFFF, write_300000, 0 },
  { 0x400000, 0x401FFF, NULL, palette_ram },
  { 0x800000, 0x800FFF, NULL, memcard_ram },
  { 0xD00000, 0xD0FFFF, NULL, battery_sram },
  { (unsigned int)-1, (unsigned int)-1, NULL }
};

struct STARSCREAM_DATAREGION *neogeo_writeword = neogeo_writebyte;

int cpu_hw_init (void)
{
  struct S68000CONTEXT context;

  rom_bank_1 = (unsigned char *)malloc(0x100000);      // $000000-$0FFFFF (1MB)
  ram_bank = (unsigned char *)malloc(0x010000);        // $100000-$10FFFF (64kB)
  rom_bank_2 = (unsigned char *)malloc(0x100000);      // $200000-$2FFFFF (1MB)
  palette_ram = (unsigned char *)malloc(0x002000);     // $400000-$401FFF (8kB)
  memcard_ram = (unsigned char *)malloc(0x001000);     // $800000-$800FFF (4kB)
  system_bios = (unsigned char *)malloc(0x020000);     // $C00000-$C1FFFF (128kB)
  battery_sram = (unsigned char *)malloc(0x010000);    // $D00000-$D0FFFF (64kB)

  if (!rom_bank_1 || !ram_bank || !rom_bank_2 || !palette_ram || !memcard_ram || !system_bios || !battery_sram)
    exit (0);

  vectors = (sc[1] == 0 ? system_bios : rom_bank_1);

  // set the offsets in program fetch
  int i = 0;
  neogeo_programfetch[i].offset = (unsigned)vectors - neogeo_programfetch[i].lowaddr; i++;
  neogeo_programfetch[i].offset = (unsigned)rom_bank_1 - neogeo_programfetch[i].lowaddr; i++;
  neogeo_programfetch[i].offset = (unsigned)ram_bank - neogeo_programfetch[i].lowaddr; i++;
  neogeo_programfetch[i].offset = (unsigned)rom_bank_2 - neogeo_programfetch[i].lowaddr; i++;
  neogeo_programfetch[i].offset = (unsigned)system_bios - neogeo_programfetch[i].lowaddr; i++;

  i = 0;
  neogeo_readbyte[i++].userdata = vectors;
  neogeo_readbyte[i++].userdata = rom_bank_1;
  neogeo_readbyte[i++].userdata = ram_bank;
  neogeo_readbyte[i++].userdata = rom_bank_2;
  neogeo_readbyte[i++].userdata = palette_ram;
  neogeo_readbyte[i++].userdata = memcard_ram;
  neogeo_readbyte[i++].userdata = system_bios;
  neogeo_readbyte[i++].userdata = battery_sram;

  i = 0;
  neogeo_writebyte[i++].userdata = ram_bank;
  neogeo_writebyte[i++].userdata = palette_ram;
  neogeo_writebyte[i++].userdata = memcard_ram;
  neogeo_writebyte[i++].userdata = battery_sram;

  s68000init ();

  s68000context.s_fetch = neogeo_programfetch;
  s68000context.u_fetch = neogeo_programfetch;
  
  s68000context.s_readbyte  = neogeo_readbyte;
  s68000context.u_readbyte  = neogeo_readbyte;
  s68000context.s_readword  = neogeo_readword;
  s68000context.u_readword  = neogeo_readword;
  s68000context.s_writebyte = neogeo_writebyte;
  s68000context.u_writebyte = neogeo_writebyte;
  s68000context.s_writeword = neogeo_writeword;
  s68000context.u_writeword = neogeo_writeword;

  return (0);
}

int cpu_hw_deinit (void)
{
  free (rom_bank_1);
  free (ram_bank);
  free (rom_bank_2);
  free (palette_ram);
  free (memcard_ram);
  free (system_bios);
  free (battery_sram);

  return (0);
}

#define EXEC_SUCCESS        0x80000000
#define EXEC_OUT_OF_RANGE   0x80000001
#define EXEC_DOUBLE_FAULT   0xFFFFFFFF

int main(int argc, char *argv[])
{
  cpu_hw_init ();

  // read system bios
  FILE *fp = fopen ("sp-s2.sp1", "rb");
  fread (system_bios, 1, 0x20000, fp);
  fclose (fp);

  int sret = s68000reset ();
  if (sret != 0) printf ("s68000reset() failed with %d\n", sret);

  printf ("A7=$%X, PC=$%X\n", s68000context.areg[7], s68000context.pc);

  unsigned uret;
  int i;
  //for (i=0; i<20; i++)
  while (1)
  {
    uret = s68000exec(1);
    if (uret != EXEC_SUCCESS)
      printf ("s68000exec() failed with $%X\n", uret);
    printf ("%d: PC=$%X\n", i, s68000context.pc);
  }

  cpu_hw_deinit ();

  printf ("Done!\n");
}
