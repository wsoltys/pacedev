#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALLEGRO_USE_CONSOLE
#include <allegro.h>

#include "starcpu.h"

//#define VERBOSE_HW_REGS
//#define VERBOSE_VRAM_D
//#define VERBOSE_ALL

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

static unsigned char *vram;             // 128kB not mapped into CPU address space
static unsigned short int *vram_w;      // pointer to previous
static unsigned char *sfix;             // 128kB fixed tile data

typedef struct
{
  unsigned char       sysstat_b;
  unsigned char       swpbios_rom;
  unsigned char       sramlock_ulock;
  unsigned char       palbank;

  // video
  unsigned short int  vramad;
  unsigned short int  vramrw;
  unsigned short int  vraminc;
  unsigned short int  hblank_cnt;

} REGS_T, *PREGS_T;

static REGS_T   regs;

FILE *LOGOUT = 0;

static unsigned read_300000_byte (unsigned a, unsigned d);
static unsigned read_300000_word (unsigned a, unsigned d);
static unsigned write_300000_byte (unsigned a, unsigned d);
static unsigned write_300000_word (unsigned a, unsigned d);

static unsigned read_320000_byte (unsigned a, unsigned d);
static unsigned read_320000_word (unsigned a, unsigned d);
static unsigned write_320000_byte (unsigned a, unsigned d);
static unsigned write_320000_word (unsigned a, unsigned d);

static unsigned read_340000_byte (unsigned a, unsigned d);
static unsigned read_340000_word (unsigned a, unsigned d);

static unsigned read_380000_byte (unsigned a, unsigned d);
static unsigned read_380000_word (unsigned a, unsigned d);
static unsigned write_380000_byte (unsigned a, unsigned d);
static unsigned write_380000_word (unsigned a, unsigned d);

static unsigned write_3A0000_byte (unsigned a, unsigned d);
static unsigned write_3A0000_word (unsigned a, unsigned d);

static unsigned read_3C0000_byte (unsigned a, unsigned d);
static unsigned read_3C0000_word (unsigned a, unsigned d);
static unsigned write_3C0000_byte (unsigned a, unsigned d);
static unsigned write_3C0000_word (unsigned a, unsigned d);

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
  { 0x300000, 0x31FFFF, (void *)read_300000_byte, 0 },
  { 0x320000, 0x33FFFF, (void *)read_320000_byte, 0 },
  { 0x340000, 0x35FFFF, (void *)read_340000_byte, 0 },
  { 0x380000, 0x39FFFF, (void *)read_380000_byte, 0 },
  { 0x3C0000, 0x3DFFFF, (void *)read_3C0000_byte, 0 },
  { 0x400000, 0x401FFF, NULL, palette_ram },
  { 0x800000, 0x800FFF, NULL, memcard_ram },
  { 0xC00000, 0xC1FFFF, NULL, system_bios },
  { 0xD00000, 0xD0FFFF, NULL, battery_sram },
  { (unsigned int)-1, (unsigned int)-1, NULL }
};
#define NUM_READBYTE (sizeof(neogeo_readbyte)/sizeof(STARSCREAM_DATAREGION))

struct STARSCREAM_DATAREGION neogeo_readword[NUM_READBYTE];

struct STARSCREAM_DATAREGION neogeo_writebyte[] = 
{
  { 0x100000, 0x10FFFF, NULL, ram_bank },
  { 0x300000, 0x31FFFF, (void *)write_300000_byte, 0 },
  { 0x320000, 0x33FFFF, (void *)write_320000_byte, 0 },
  { 0x380000, 0x39FFFF, (void *)write_380000_byte, 0 },
  { 0x3A0000, 0x3AFFFF, (void *)write_3A0000_byte, 0 },
  { 0x3C0000, 0x3DFFFF, (void *)write_3C0000_byte, 0 },
  { 0x400000, 0x401FFF, NULL, palette_ram },
  { 0x800000, 0x800FFF, NULL, memcard_ram },
  { 0xD00000, 0xD0FFFF, NULL, battery_sram },
  { (unsigned int)-1, (unsigned int)-1, NULL }
};
#define NUM_WRITEBYTE (sizeof(neogeo_writebyte)/sizeof(STARSCREAM_DATAREGION))

struct STARSCREAM_DATAREGION neogeo_writeword[NUM_WRITEBYTE];

int cpu_hw_init (void)
{
  rom_bank_1 = (unsigned char *)malloc(0x100000);     // $000000-$0FFFFF (1MB)
  ram_bank = (unsigned char *)malloc(0x010000);       // $100000-$10FFFF (64kB)
  rom_bank_2 = (unsigned char *)malloc(0x100000);     // $200000-$2FFFFF (1MB)
  palette_ram = (unsigned char *)malloc(0x002000);    // $400000-$401FFF (8kB)
  memcard_ram = (unsigned char *)malloc(0x001000);    // $800000-$800FFF (4kB)
  system_bios = (unsigned char *)malloc(0x020000);    // $C00000-$C1FFFF (128kB)
  battery_sram = (unsigned char *)malloc(0x010000);   // $D00000-$D0FFFF (64kB)

  if (!rom_bank_1 || !ram_bank || !rom_bank_2 || !palette_ram || !memcard_ram || !system_bios || !battery_sram)
    exit (0);

  vram = (unsigned char *)malloc(0x20000);            // 128kB video ram
  sfix = (unsigned char *)malloc(0x20000);            // 128kB fix tile ram
  vram_w = (unsigned short int *)vram;
  if (!vram | !sfix)
    exit (0);

  regs.swpbios_rom = 0;
  vectors = (regs.swpbios_rom == 0 ? system_bios : rom_bank_1);

  regs.sysstat_b = 0xFF;

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
  i += 5;
  neogeo_readbyte[i++].userdata = palette_ram;
  neogeo_readbyte[i++].userdata = memcard_ram;
  neogeo_readbyte[i++].userdata = system_bios;
  neogeo_readbyte[i++].userdata = battery_sram;

  memcpy (neogeo_readword, neogeo_readbyte, sizeof(neogeo_readbyte));
  neogeo_readword[4].memorycall = (void *)read_300000_word;
  neogeo_readword[5].memorycall = (void *)read_320000_word;
  neogeo_readword[6].memorycall = (void *)read_340000_word;
  neogeo_readword[7].memorycall = (void *)read_380000_word;
  neogeo_readword[8].memorycall = (void *)read_3C0000_word;

  i = 0;
  neogeo_writebyte[i++].userdata = ram_bank;
  i += 5;
  neogeo_writebyte[i++].userdata = palette_ram;
  neogeo_writebyte[i++].userdata = memcard_ram;
  neogeo_writebyte[i++].userdata = battery_sram;

  memcpy (neogeo_writeword, neogeo_writebyte, sizeof(neogeo_writebyte));
  neogeo_writeword[1].memorycall = (void *)write_300000_word;
  neogeo_writeword[2].memorycall = (void *)write_320000_word;
  neogeo_writeword[3].memorycall = (void *)write_380000_word;
  neogeo_writeword[4].memorycall = (void *)write_3A0000_word;
  neogeo_writeword[5].memorycall = (void *)write_3C0000_word;

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

  free (vram);

  return (0);
}

#define EXEC_SUCCESS        0x80000000
#define EXEC_OUT_OF_RANGE   0x80000001
#define EXEC_DOUBLE_FAULT   0xFFFFFFFF

unsigned read_300000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  unsigned val = 0;

  switch(offset & 0x80)
  {
    case 0x00:
      val = 0xFE;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_dipsw($%02X)\n", val);
      #endif
      break;
    case 0x80:
      val = 0xFF;
      //printf ("p1cnt=$%X\n", val);
      break;
    default:
      printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);
      break;
  }

  return (val);
}

unsigned read_300000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  unsigned val = 0;

  printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);

  return (val);
}

unsigned write_300000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  if (offset & (1<<0))
  {
    #ifdef VERBOSE_ALL
      printf ("kick watchdog\n");
    #endif
  }
  else
    printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned write_300000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned read_320000_byte (unsigned a, unsigned d)
{
  static unsigned char val = 0;

  // fudge clock ticking over...
  val ^= 0x40;
  if (val & 0x40) 
    val ^= 1;

  #ifdef VERBOSE_HW_REG
    printf ("reg_sysstat_a=$%X\n", val);
  #endif

  return (val);
}

unsigned read_320000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, a, d);

  return (0);
}

unsigned write_320000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned write_320000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned read_340000_byte (unsigned a, unsigned d)
{
  //printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);

  // input port 1 (active low)
  return (0xFF);
}

unsigned read_340000_word (unsigned a, unsigned d)
{
  printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);

  return (0);
}

unsigned read_380000_byte (unsigned a, unsigned d)
{
  // reg_sysstat_b (active low)
  //printf ("sysstat_b=$%X\n", regs.sysstat_b);

  return (regs.sysstat_b);
}

unsigned read_380000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned write_380000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x7E;
  switch (offset)
  {
    case 0x00 :
      // no idea?!?
      break;
    case 0x30 :
      #ifdef VERBOSE_ALL
        printf ("led latch($%X)\n", d);
      #endif
      break;
    case 0x40 :
      #ifdef VERBOSE_ALL
        printf ("led send($%X)\n", d);
      #endif
      break;
    case 0x50 :
      #ifdef VERBOSE_ALL
        printf ("rtc($%X)\n", d);
      #endif
    case 0x64 : case 0x66 :
      #ifdef VERBOSE_ALL
        printf ("coin lockout($%X)\n", d);
      #endif
      break;
    default :
      printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);
      break;
  }

  return (0);
}

unsigned write_380000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned write_3A0000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x1F;
  switch (offset)
  {
    case 0x03 :
      regs.swpbios_rom = 0;
      vectors = system_bios;
      neogeo_programfetch[0].offset = (unsigned)vectors - neogeo_programfetch[0].lowaddr;
      neogeo_readbyte[0].userdata = vectors;
      neogeo_readword[0].userdata = vectors;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_swpbios\n");
      #endif
      break;
    case 0x0A : case 0x0B :
      #ifdef VERBOSE_HW_REGS
        printf ("reg_brdfix\n");
      #endif
      break;
    case 0x0C : case 0x0D :
      regs.sramlock_ulock = 0; // lock
      #ifdef VERBOSE_HW_REGS
        printf ("reg_sramlock\n");
      #endif
      break;
    case 0x0E : case 0x0F :
      regs.palbank = 1;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_palbank1\n");
      #endif
      break;
    case 0x13 :
      regs.swpbios_rom = 1;
      vectors = rom_bank_1;
      neogeo_programfetch[0].offset = (unsigned)vectors - neogeo_programfetch[0].lowaddr;
      neogeo_readbyte[0].userdata = vectors;
      neogeo_readword[0].userdata = vectors;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_swprom\n");
      #endif
      break;
    case 0x1C : case 0x1D :
      regs.sramlock_ulock = 1; // unlock
      #ifdef VERBOSE_HW_REGS
        printf ("reg_sramulock\n");
      #endif
      break;
    case 0x1E : case 0x1F :
      regs.palbank = 0;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_palbank0\n");
      #endif
      break;
    default :
      printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);
      break;
  }

  return (0);
}

unsigned write_3A0000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x00FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned read_3C0000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned read_3C0000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x0E;
  unsigned short int val;

  switch (offset)
  {
    case 0x02 :
      // read word from video memory (word addressed)
      val = *(vram_w+regs.vramad);
      #ifdef VERBOSE_VRAM_D
        printf ("reg_vramrw($%X)=$%X\n", regs.vramad, val);
      #endif
      //regs.vramad += regs.vraminc;
      break;
    default :
      break;
  }

  return (val);
}

unsigned write_3C0000_byte (unsigned a, unsigned d)
{
  unsigned offset = a & 0x01FFFF;
  printf ("%s($%X,$%X)\n", __FUNCTION__, offset, d);

  return (0);
}

unsigned write_3C0000_word (unsigned a, unsigned d)
{
  unsigned offset = a & 0x0E;
  switch (offset)
  {
    case 0x00 :
      regs.vramad = (unsigned short int)d;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_vramad($%X)\n", d);
      #endif
      break;
    case 0x02 :
      // write word to video memory (word addressed)
      *(vram_w+regs.vramad) = d;
      #ifdef VERBOSE_VRAM_D
        printf ("reg_vramrw($%X,$%X)\n", regs.vramad, d);
      #endif
      regs.vramad += regs.vraminc;
      break;
    case 0x04 :
      regs.vraminc = (unsigned short int)d;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_vraminc($%X)\n", d);
      #endif
      break;
    case 0x06 :
      regs.hblank_cnt = (unsigned short int)d;
      #ifdef VERBOSE_HW_REGS
        printf ("reg_hblank_cnt($%X)\n", d);
      #endif
      break;
    case 0x0C :
      #ifdef VERBOSE_HW_REGS
        printf ("reg_irqack($%X)\n", d);
      #endif
      break;
    default :
      printf ("%s($%X,$%X) - UNKNOWN!\n", __FUNCTION__, a, d);
      break;
  }

  return (0);
}

void show_sfix_tile (int x, int y, unsigned short int c)
{
  unsigned char *data = sfix + (c<<5);
  int pel;

  for (int yy=0; yy<8; yy++)
    for (int xx=0; xx<8; xx++)
    {
      if ((xx&1) == 0)
        pel = (*(data + (((xx&6)^4)<<2) + yy)) & 0x0F;
      else
        pel = (*(data + (((xx&6)^4)<<2) + yy)) >> 4;
      putpixel (screen, x+xx, y+yy, (pel&1) ? 1 : 0);
    }
}

int show_sfix (void)
{
  for (int y=0; y<32; y++)
  {
    for (int x=0; x<40; x++)
    {
      int a = y+(x<<5);
      int c = vram_w[0x7000+a] & 0xFFF;

      show_sfix_tile (x*8, y*8, c&0xff);
    }
  }
  return (0);
}

//#define SWAP(x) (((x)<<8)&0xFF00)|(((x)>>8)&0x00FF)
#define SWAP(x) (x)
#define NOP     SWAP(0x4E71)

void patch_bios (void)
{
  unsigned short int *p;

  // bcs.w calendar_test_fail
  p = (unsigned short int *)(system_bios + 0x11c14);
  *(p++) = NOP; *(p++) = NOP;

  // bcc.w calendar_test_fail
  p = (unsigned short int *)(system_bios + 0x11c1c);
  *(p++) = NOP; *(p++) = NOP;

  // bne.w fail (system rom)
  p = (unsigned short int *)(system_bios + 0x11c62);
  *(p++) = NOP; *(p++) = NOP;
}

int main(int argc, char *argv[])
{
  unsigned long int cycles = 0;

  if (--argc)
    cycles = atol(argv[1]);

  FILE *LOGOUT = fopen ("debug.log", "wt");
  if (!LOGOUT) exit (0);

  cpu_hw_init ();

  // read system bios
  FILE *fp = fopen ("sp-s2.sp1", "rb");
  fread (system_bios, 1, 0x20000, fp);
  fclose (fp);
  #if 0
  fp = fopen ("bios.bin", "wb");
  for (int i=0; i<0x20000; i+=2)
  {
    fwrite (system_bios+i+1, 1, 1, fp);
    fwrite (system_bios+i+0, 1, 1, fp);
  }
  fclose (fp);
  #endif
  fp = fopen ("sfix.sfx", "rb");
  fread (sfix, 1, 0x20000, fp);
  fclose (fp);
  #if 0
  fp = fopen ("sfix.x2", "wb");
  for (int i=0; i<0x20000; i++)
  {
    fwrite((sfix+i), 1, 1, fp);
    fwrite((sfix+i), 1, 1, fp);
  }
  fclose (fp);
  #endif

  patch_bios ();

  int sret = s68000reset ();
  if (sret != 0) printf ("s68000reset() failed with %d\n", sret);

  printf ("A7=$%X, PC=$%X\n", s68000context.areg[7], s68000context.pc);

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 224, 0, 0);

  #if 0
  for (int t=0; t<4096; t++)
  {
    show_sfix_tile ((t%40)*8, (((t/40)%32)*8), t);
    if (t%(40*32) == 40*32-1)
    {
      while (!key[KEY_ESC]);
      while (key[KEY_ESC]);	  
    }
  }
  #endif

  unsigned uret;
  unsigned long int i;
  int frame = 0;
  while (cycles == 0 || i < cycles)
  {
    uret = s68000exec(200000);
    if (uret != EXEC_SUCCESS)
      printf ("s68000exec() failed with $%X\n", uret);
    #ifdef VERBOSE_PC
      printf ("%d: PC=$%X\n", i, s68000context.pc);
    #endif

    s68000interrupt (1, -1);

    if (++frame == 60)
    {
      show_sfix ();
      frame = 0;
    }

    if (keypressed ())
    {
      if (key[KEY_ESC])
        break;

      if (key[KEY_1])
        regs.sysstat_b &= ~(1<<0);
      else
        regs.sysstat_b |= (1<<0);
    }

    i++;
  }

  while (!key[KEY_ESC]);
  while (key[KEY_ESC]);	  

  fclose (LOGOUT);

  #if 0
    fp = fopen ("vram1.bin", "wb");
    fwrite (vram_w+0x7000, 2, 1024, fp);
    fclose (fp);
    fp = fopen ("vram2.bin", "wb");
    fwrite (vram_w+0x7400, 2, 256, fp);
    fclose (fp);
  #endif

  cpu_hw_deinit ();

  printf ("Done!\n");

  allegro_exit ();
}

END_OF_MAIN();
