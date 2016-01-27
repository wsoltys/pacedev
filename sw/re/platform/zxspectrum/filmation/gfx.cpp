#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

// pandora: run msys.bat and cd to this directory
//          g++ kl.cpp -o kl -lallegro-4.4.2-md

// neogeo:  d:\mingw_something\setenv.bat
//          g++ gfx.cpp -o xgf -lalleg

#define DO_C_DATA

//#define DO_ASCII
//#define DO_PARSE_MAP
//#define DO_GA
//#define DO_FONT
//#define DO_SPRITE_DATA
//#define DO_SPRITE_TABLE
//#define DO_BLOCK_DATA
//#define DO_BG_DATA

const char *to_ascii = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
uint8_t ram[64*1024];
uint8_t ascii[64*1024];
unsigned widest = 0;
unsigned highest = 0;
FILE *fpdbg;

static void plot_character (unsigned ch, unsigned cx, unsigned cy, unsigned c)
{
  for (unsigned y=0; y<8; y++)
  {
    unsigned char d = ram[0x6108+ch*8+y];
    
    for (unsigned b=0; b<8; b++)
    {
      if (d & (1<<7))
        putpixel (screen, cx+b, cy+y, c);
      d <<= 1;
    }
  }
}

static void plot_ascii_character (unsigned ch, unsigned cx, unsigned cy, unsigned c)
{
  unsigned i;
  
  for (i=0; to_ascii[i]; i++)
    if (to_ascii[i] == ch)
      break;
      
  if (i == 40)
    return;
    
  plot_character (i, cx, cy, c);    
}

static unsigned plot_sprite_data (unsigned s, unsigned f, unsigned p, unsigned px, unsigned py, unsigned c, unsigned &w, unsigned &h)
{          
  w = ram[p++] & 0x3f;
  h = ram[p++];

  if (w > widest)
    widest = w;
  if (h > highest)
    highest = h;

  fprintf (fpdbg, "SPR=%03d A=$%04X (X=%02d,Y=%02d)\n", 
            s, p-2, w, h);
        
  for (unsigned y=0; y<h; y++)
    for (unsigned x=0; x<w; x++)
    {
      // skip mask
      p++;
      unsigned char d = ram[p++];
      for (unsigned b=0; b<8; b++)
      {
        if (d & (1<<7))
          if (f & (1<<6))
            if (f & (1<<7))
              putpixel (screen, px+(w*8-(x*8+b)), py+y, 3);
            else
              putpixel (screen, px+(w*8-(x*8+b)), py+(h-y), 2);
          else
            if (f & (1<<7))
              putpixel (screen, px+x*8+b, py+y, 1);
            else
              putpixel (screen, px+x*8+b, py+(h-y), 7);
                
        d <<= 1;
      }
    }

  w *= 8;    
  return (p);
}

void plot_sprite (unsigned s, unsigned f, unsigned x, unsigned y, unsigned c, unsigned &w, unsigned &h)
{
  // get sprite data address from table
  unsigned p = ram[0x7112+s*2+1];
  p = (p<<8) | ram[0x7112+s*2];
  
  plot_sprite_data (s, f, p, x, y, 3, w, h);
}

#pragma pack(1)
typedef struct
{
  uint8_t   i;
  uint16_t  hl_, de_, bc_, af_;
  uint16_t  hl, de, bc, iy, ix;
  uint8_t   interrupt;
  uint8_t   r;
  uint16_t  af, sp;
  uint8_t   intmode;
  uint8_t   bordercolor;
      
} SNAHDR, *PSNAHDR;

//#define SWAP(d) (((d<<8)&0xFF00)|((d>>8)&0x00FF))
#define SWAP(d) (d)

void dump_sna_hdr (PSNAHDR hdr)
{
  fprintf (stderr, "%16.16s = 0x%02X\n", "I", hdr->i);
  fprintf (stderr, "%16.16s = 0x%04X\n", "HL'", SWAP(hdr->hl_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "DE'", SWAP(hdr->de_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "BC'", SWAP(hdr->bc_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "AF'", SWAP(hdr->af_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "HL", SWAP(hdr->hl));
  fprintf (stderr, "%16.16s = 0x%04X\n", "DE", SWAP(hdr->de));
  fprintf (stderr, "%16.16s = 0x%04X\n", "BC", SWAP(hdr->bc));
  fprintf (stderr, "%16.16s = 0x%04X\n", "IY", SWAP(hdr->iy));
  fprintf (stderr, "%16.16s = 0x%04X\n", "IX", SWAP(hdr->ix));
  fprintf (stderr, "%16.16s = 0x%02X\n", "Interrupt", hdr->interrupt);
  fprintf (stderr, "%16.16s = 0x%02X\n", "R", hdr->r);
  fprintf (stderr, "%16.16s = 0x%04X\n", "AF", SWAP(hdr->af));
  fprintf (stderr, "%16.16s = 0x%04X\n", "SP", SWAP(hdr->sp));
  fprintf (stderr, "%16.16s = 0x%02X\n", "IntMode", hdr->intmode);
  fprintf (stderr, "%16.16s = 0x%02X\n", "BorderColor", hdr->bordercolor);

  uint16_t  sp = SWAP(hdr->sp);
  uint16_t  ret = ram[sp+1];
  ret = (ret<<8)|ram[sp+0];
  fprintf (stderr, "%16.16s = 0x%04X\n", "RET", ret);
}

void main (int argc, char *argv[])
{
	FILE *fp, *fp2;
	struct stat	fs;
	int					fd;
	
	char				buf[1024];

  unsigned t;
  unsigned w, h;

  fpdbg = fopen ("debug.txt", "wt");

  // ALIEN8
  
	fp = fopen ("alien8.sna", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[16384-27], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

  dump_sna_hdr ((PSNAHDR)&ram[16384-27]);

	fp = fopen ("alien8.bin", "wb");
	// write the relevant areas
	fwrite (&ram[0x6288], 0xd1eb-0x6288, 1, fp);
	fclose (fp);

  unsigned p;

  {
  // location table
  unsigned locations = 0;
  p = 0x6469;
  fprintf (stdout, "uint8_t location_tbl[] = \n{\n");
  while (p < 0x73C8)
  {
    uint8_t n = ram[p+1];
    fprintf (stdout, "  // $%04X\n", p);
    fprintf (stdout, "  %d, %d, %d,\n",
              ram[p], ram[p+1], ram[p+2]);
    p += 3;
    locations++;
    for (unsigned i=0; i<n-2; i++)
    {
      if ((i%8)==0)
        fprintf (stdout, "  ");
      fprintf (stdout, "0x%02X", ram[p++]);
      if (p < 0x73C8)
        fprintf (stdout, ", ");
      if ((i%8)==7 || i==n-3)
        fprintf (stdout, "\n");
    }
  }
  fprintf (stdout, "};\n\n");
  fprintf (stderr, "#locations = %d\n", locations);
  }

  // KNIGHT LORE
  	
	fp = fopen ("knightlore.sna", "rb");
	if (!fp)
		exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[16384-27], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

  dump_sna_hdr ((PSNAHDR)&ram[16384-27]);
  
	fp = fopen ("knightlore.bin", "wb");
	// write the relevant areas
	fwrite (&ram[0x6108], 0xd8f3-0x6108, 1, fp);
	fclose (fp);

#ifdef DO_C_DATA
  fp2 = fopen ("data.c", "wt");
  
  // font
  p = 0x6108;
  const char *font = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  fprintf (fp2, "uint8_t kl_font[][8] = \n{\n" );
  for (int c=0; c<40; c++)
  {
    fprintf (fp2, "  { ");
    for (int b=0; b<8; b++)
    {
      fprintf (fp2, "0x%02X, ", ram[p]);
      p++;
    }
    fprintf (fp2, "},  // '%c'\n", font[c]);
  }
  fprintf (fp2, "};\n\n");  

  // room size table
  p = 0x6248;
  fprintf (fp2, "ROOM_SIZE_T room_size_tbl[] = \n{\n");
  while (p < 0x6251)
  {
    fprintf (fp2, "  { %02d, %02d, %02d }",
              ram[p], ram[p+1], ram[p+2]);
    if (p < 0x6251-3)
      fprintf (fp2, ",");
    fprintf (fp2, "\n");
    p += 3;
  }
  fprintf (fp2, "};\n\n");
  
  // location table
  unsigned locations = 0;
  p = 0x6251;
  fprintf (fp2, "uint8_t location_tbl[] = \n{\n");
  while (p < 0x6BD1)
  {
    uint8_t n = ram[p+1];
    fprintf (fp2, "  %d, %d, %d,\n",
              ram[p], ram[p+1], ram[p+2]);
    p += 3;
    locations++;
    for (unsigned i=0; i<n-2; i++)
    {
      if ((i%8)==0)
        fprintf (fp2, "  ");
      fprintf (fp2, "0x%02X", ram[p++]);
      if (p < 0x6BD1)
        fprintf (fp2, ", ");
      if ((i%8)==7 || i==n-3)
        fprintf (fp2, "\n");
    }
  }
  fprintf (fp2, "};\n\n");
  fprintf (stderr, "#locations = %d\n", locations);

  // block type table

  typedef struct
  {
    char        label[32];
    uint16_t    addr;
    
  } BLKTYP_T, *PBLKTYP_T;

  static BLKTYP_T blktyp[] =
  {
    { "block", 0 },
    { "fire", 0 },
    { "ball_ud_y", 0 },
    { "rock", 0 },
    { "gargoyle", 0 },
    { "spike", 0 },
    { "chest", 0 },
    { "table", 0 },
    { "guard_ew", 0 },
    { "ghost", 0 },
    { "fire_ns", 0 },
    { "block_high", 0 },
    { "ball_ud_xy", 0 },
    { "guard_square", 0 },
    { "block_ew", 0 },
    { "block_ns", 0 },
    { "moveable_block", 0 },
    { "spike_high", 0 },
    { "spike_ball_fall", 0 },
    { "spike_ball_high_fall", 0 },
    { "fire_ew", 0 },
    { "dropping_block", 0 },
    { "collapsing_block", 0 },
    { "ball_bounce", 0 },
    { "ball_ud", 0 },
    { "repel_spell", 0 },
    { "gate_ud_1", 0 },
    { "gate_ud_2", 0 },
    { "ball_ud_x", 0 }
  };

  p = 0x6BD1;
  unsigned n = 0;
  for (n=0; p<0x6C0B; n++, p+=2)
  {
    blktyp[n].addr = ram[p+1];
    blktyp[n].addr = (blktyp[n].addr<<8) | ram[p];
  }
  while (p < 0x6CE2)
  {
    unsigned i;
    
    // find address
    for (i=0; i<n; i++)
      if (p == blktyp[i].addr)
        break;
    if (i == n)
      fprintf (stderr, "ERR: block_type addr=$%04X\n", p);

    // do table entry
    fprintf (fp2, "uint8_t %s[] = \n{\n", blktyp[i].label);
    do
    {
      fprintf (fp2, "  0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X,\n",
                ram[p], ram[p+1], ram[p+2], ram[p+3], ram[p+4], ram[p+5]);
      p += 6;
      
    } while (ram[p] != 0);
    fprintf (fp2, "  0");
    p++;
    fprintf (fp2,"\n};\n\n");
  }

  fprintf (fp2, "uint8_t *block_type_tbl[] = \n{\n");
  for (unsigned i=0; i<n; i++)
  {
    fprintf (fp2, "  %s%s\n", blktyp[i].label,
      (i<n-1 ? "," : ""));
  }
  fprintf (fp2, "};\n\n");
  
  // background type table
  
  static BLKTYP_T bgtyp[] =
  {
    { "arch_n", 0 },
    { "arch_e", 0 },
    { "arch_s", 0 },
    { "arch_w", 0 },
    { "tree_arch_n", 0 },
    { "tree_arch_e", 0 },
    { "tree_arch_s", 0 },
    { "tree_arch_w", 0 },
    { "gate_n", 0 },
    { "gate_e", 0 },
    { "gate_s", 0 },
    { "gate_w", 0 },
    { "wall_size_1", 0 },
    { "wall_size_2", 0 },
    { "wall_size_3", 0 },
    { "tree_room_size_1", 0 },
    { "tree_filler_w", 0 },
    { "tree_filler_n", 0 },
    { "wizard", 0 },
    { "cauldron", 0 },
    { "high_arch_e", 0 },
    { "high_arch_s", 0 },
    { "high_arch_e_base", 0 },
    { "high_arch_s_base", 0 }
  };
  
  p = 0x6CE2;
  for (n=0; p<0x6D12; n++, p+=2)
  {
    bgtyp[n].addr = ram[p+1];
    bgtyp[n].addr = (bgtyp[n].addr<<8) | ram[p];
  }
  while (p < 0x6FF2)
  {
    unsigned i;
    
    // find address
    for (i=0; i<n; i++)
      if (p == bgtyp[i].addr)
        break;
    if (i == n)
      fprintf (stderr, "ERR: bg_type addr=$%04X\n", p);

    // do table entry
    fprintf (fp2, "uint8_t %s[] = \n{\n", bgtyp[i].label);
    do
    {
      fprintf (fp2, "  0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X,\n",
                ram[p], ram[p+1], ram[p+2], ram[p+3], ram[p+4], ram[p+5], ram[p+6], ram[p+7]);
      p += 8;
      
    } while (ram[p] != 0);
    fprintf (fp2, "  0");
    p++;
    fprintf (fp2,"\n};\n\n");
  }

  fprintf (fp2, "uint8_t *background_type_tbl[] = \n{\n");
  for (unsigned i=0; i<n; i++)
  {
    fprintf (fp2, "  %s%s\n", bgtyp[i].label,
      (i<n-1 ? "," : ""));
  }
  fprintf (fp2, "};\n\n");
  
  // create object table
  p = 0x6FF2;
  fprintf (fp2, "OBJ9 special_objs_tbl[] = \n{\n");
  while (p < 0x7112)
  {
    fprintf (fp2, "  { ");
    for (int m=0; m<9; m++)
      fprintf (fp2, "0x%02X%s ", ram[p++], (m<8 ? ",":""));
    fprintf (fp2, "},\n");
  }
  fprintf (fp2, "};\n\n");

  // create table of sprite addresses
  uint16_t sprite_a[132];
  unsigned sprite_n = 0;
  p = 0x728C;
  while (p < 0xAF6C)
  {
    if (p == 0x7D98)
      p += 12;

    unsigned w = ram[p+0] & 0x3f;
    unsigned h = ram[p+1];
    
    //fprintf (stderr, "spr_%03d=$%04X\n", sprite_n, p);
    sprite_a[sprite_n++] = p;

    if (w==0 && h==0)
    {
      p += 2;
      continue;
    }

    p += 2 + w*h*2;    
  }
  //fprintf (stderr, "sprite_n=%d\n", sprite_n);

  // sprite_tbl
  fprintf (fp2, "uint8_t *sprite_tbl[] =\n{\n");
  n = 0;
  for (p=0x7112; p<0x728A; p+=2, n++)
  {
    char label[16];

    uint16_t a = ram[p+1];
    a = (a<<8) | ram[p];
    if (a == 0x728A)
      strcpy (label, "spr_nul");
    else
    {
      // find entry in lookup
      unsigned i;
      for (i=0; i<sprite_n; i++)
      {
        if (sprite_a[i] == a)
          break;
      }
      if (i < sprite_n)
        sprintf (label, "spr_%03d", i);
      else
        strcpy (label, "(ERROR)");
    }
    if ((n%6) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "%s, ", label);
    if ((n%6) == 5)
      fprintf (fp2, "\n");
  }
  fprintf (fp2, "\n};\n\n");

  // sprite graphics
  fprintf (fp2, "uint8_t spr_nul[] =\n{\n  0, 0\n};\n\n");
  p = 0x728C;
  sprite_n = 0;
  while (p < 0xAF6C)
  {
    if (p == 0x7D98)
      p += 12;

    unsigned w = ram[p+0] & 0x3f;
    unsigned h = ram[p+1];
    
    fprintf (fp2, "uint8_t spr_%03d[] =\n{\n  %d, %d,\n",
              sprite_n++, w, h);
    unsigned i;
    p += 2;
    for (unsigned i=0; i<w*h*2; i++, p++)
    {
      if ((i%8)==0) fprintf (fp2, "  ");
      fprintf (fp2, "0x%02X, ", ram[p]);
      if ((i%8)==7) fprintf (fp2, "\n");
    }
    fprintf (fp2, "\n};\n\n");
  }

  // audio data
  p = 0xb20e;
  for (int i=0; i<4; i++)
  {
    const char *label[] =
    {
      "start_game",
      "game_over",
      "game_complete",
      "menu"
    };
    fprintf (fp2, "uint8_t %s_tune[] = \n{\n", label[i]);
    unsigned n=0;
    do
    {
      if ((n%8)==0) fprintf (fp2, "  ");
      fprintf (fp2, "0x%02X", ram[p]);
      if (ram[p]!=0xff) fprintf (fp2, ", ");
      if ((n%8)==7 || ram[p]==0xff) fprintf (fp2, "\n");
      n++;
    } while (ram[p++] != 0xff);
    fprintf (fp2, "};\n\n");
  }

  // cauldron_bubbles
  p = 0xb8c8;
  fprintf (fp2, "uint8_t cauldron_bubbles[] = \n{\n");
  for (unsigned i=0; p<0xb8da; i++, p++)
  {
    if (i%8==0) fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p]);
    if (p<0xb8da-1) fprintf (fp2, ", ");
    if (i%8==7) fprintf (fp2, "\n");
  }
  fprintf (fp2, "\n};\n\n");

  // complete colours
  p = 0xbad2;
  fprintf (fp2, "uint8_t complete_colours[] = \n{\n");
  for (int i=0; i<6; i++)
  {
    if ((i%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((i%8) == 7)
      fprintf (fp2, "\n");
    else
      fprintf (fp2, ", ");
  }
  fprintf (fp2, "};\n\n");

  // complete_xy
  p = 0xbad8;
  fprintf (fp2, "uint8_t complete_xy[] = \n{\n");
  for (int xy=0; xy<12; xy++)
  {
    if ((xy%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((xy%8) != 7 || xy < 15)
      fprintf (fp2, ", ");
    if ((xy%8) == 7)
      fprintf (fp2, "\n");
  }
  fprintf (fp2, "};\n\n");

  // complete_text
  fprintf (fp2, "const char *complete_text[] = \n{\n");
  while (p < 0xBB4C)
  {
    fprintf (fp2, "  \"");
    do
    {
      fprintf (fp2, "%c", to_ascii[ram[p]&0x7f]);
    } while (ram[p++] < 128);
    fprintf (fp2, "\"");
    if (p < 0xBB4C)
      fprintf (fp2, ", ");
    fprintf (fp2, "\n");  
  }
  fprintf (fp2, "};\n\n");

  // gameover colours
  p = 0xbb4c;
  fprintf (fp2, "uint8_t gameover_colours[] = \n{\n");
  for (int i=0; i<6; i++)
  {
    if ((i%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((i%8) == 7)
      fprintf (fp2, "\n");
    else
      fprintf (fp2, ", ");
  }
  fprintf (fp2, "};\n\n");

  // gameover_xy
  p = 0xbb52;
  fprintf (fp2, "uint8_t gameover_xy[] = \n{\n");
  for (int xy=0; xy<12; xy++)
  {
    if ((xy%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((xy%8) != 7 || xy < 15)
      fprintf (fp2, ", ");
    if ((xy%8) == 7)
      fprintf (fp2, "\n");
  }
  fprintf (fp2, "};\n\n");

  // gameover_text
  fprintf (fp2, "const char *gameover_text[] = \n{\n");
  while (p < 0xbbb7)
  {
    fprintf (fp2, "  \"");
    do
    {
      fprintf (fp2, "%c", to_ascii[ram[p]&0x7f]);
    } while (ram[p++] < 128);
    fprintf (fp2, "\"");
    if (p < 0xbbb7)
      fprintf (fp2, ", ");
    fprintf (fp2, "\n");  
  }
  fprintf (fp2, "};\n\n");

  // days_txt
  p = 0xbce7;
  fprintf (fp2, "uint8_t days_txt[] = \n{\n  ");
  for (unsigned i=0; i<5;i++)
  {
    fprintf (fp2, "0x%02x", ram[p++]);
    if (i<4) fprintf (fp2, ", ");
  }
  fprintf (fp2, "\n};\n\n");

  // rating_text
  p = 0xbbc7;
  fprintf (fp2, "const RATING rating_tbl[] = \n{\n");
  while (p < 0xbc10)
  {
    fprintf (fp2, "  { 0x%02X, \"", ram[p++]);
    do
    {
      fprintf (fp2, "%c", to_ascii[ram[p]&0x7f]);
    } while (ram[p++] < 128);
    fprintf (fp2, "\" }");
    if (p < 0xbc10)
      fprintf (fp2, ", ");
    fprintf (fp2, "\n");  
  }
  fprintf (fp2, "};\n\n");

  // days_font
  p = 0xbcec;
  fprintf (fp2, "uint8_t days_font[][8] = \n{\n");
  for (int i=0; p<0xbd0c; i++)
  {
    if ((i%8) == 0)
      fprintf (fp2, "  { ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if (p<0xbd0c)
      fprintf (fp2, ", ");
    if ((i%8) == 7)
      fprintf (fp2, " }\n");
  }
  fprintf (fp2, "};\n\n");


  // menu colours
  p = 0xbda2;
  fprintf (fp2, "uint8_t menu_colours[] = \n{\n");
  for (int i=0; i<8; i++)
  {
    if ((i%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((i%8) == 7)
      fprintf (fp2, "\n");
    else
      fprintf (fp2, ", ");
  }
  fprintf (fp2, "};\n\n");

  // menu_xy
  p = 0xbdaa;
  fprintf (fp2, "uint8_t menu_xy[] = \n{\n");
  for (int xy=0; xy<16; xy++)
  {
    if ((xy%8) == 0)
      fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p++]);
    if ((xy%8) != 7 || xy < 15)
      fprintf (fp2, ", ");
    if ((xy%8) == 7)
      fprintf (fp2, "\n");
  }
  fprintf (fp2, "};\n\n");

  // menu_text
  fprintf (fp2, "const char *menu_text[] = \n{\n");
  while (p < 0xBE31)
  {
    fprintf (fp2, "  \"");
    do
    {
      fprintf (fp2, "%c", to_ascii[ram[p]&0x7f]);
    } while (ram[p++] < 128);
    fprintf (fp2, "\"");
    if (p < 0xBE31)
      fprintf (fp2, ", ");
    fprintf (fp2, "\n");  
  }
  fprintf (fp2, "};\n\n");

  // objects_required
  p = 0xc27d;
  fprintf (fp2, "uint8_t objects_required[] = \n{\n");
  for (unsigned i=0; p<0xc28b; i++, p++)
  {
    if (i%8==0) fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p]);
    if (p<0xc28b-1) fprintf (fp2, ", ");
    if (i%8==7) fprintf (fp2, "\n");
  }
  fprintf (fp2, "\n};\n\n");

  // sun_moon_yoff
  p = 0xc440;
  fprintf (fp2, "uint8_t sun_moon_yoff[] = \n{\n");
  for (unsigned i=0; p<0xc44d; i++, p++)
  {
    if (i%8==0) fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p]);
    if (p<0xc44d-1) fprintf (fp2, ", ");
    if (i%8==7) fprintf (fp2, "\n");
  }
  fprintf (fp2, "\n};\n\n");

  // player sprite init data
  p = 0xd1a1;
  fprintf (fp2, "uint8_t plyr_spr_init_data[] = \n{\n");
  for (unsigned i=0; p<0xd1b1; i++, p++)
  {
    if (i%8==0) fprintf (fp2, "  ");
    fprintf (fp2, "0x%02X", ram[p]);
    if (p<0xd1b1-1) fprintf (fp2, ", ");
    if (i%8==7) fprintf (fp2, "\n");
  }
  fprintf (fp2, "\n};\n\n");

  // start locations
  p = 0xd1e2;
  fprintf (fp2, "uint8_t start_locations[] = \n{\n");
  fprintf (fp2, "  0x%02X, 0x%02X, 0x%02X, 0x%02X\n",
            ram[p+0], ram[p+1], ram[p+2], ram[p+3]);
  fprintf (fp2, "};\n\n");

  // panel data
  p = 0xd27e;
  fprintf (fp2, "uint8_t panel_data[] = \n{\n");
  for (unsigned i=0; i<6; i++)
  {
    fprintf (fp2, "  0x%02X, 0x%02X, 0x%02X, 0x%02X,\n",
              ram[p+0], ram[p+1], ram[p+2], ram[p+3]);
    p += 4;
  }
  fprintf (fp2, "};\n\n");

  // border_data
  p = 0xd2cf;
  fprintf (fp2, "uint8_t border_data[][4] =\n{\n");
  fprintf (fp2, "  // sprite index, flags, x, y\n");
  for (int i=0; i<8; i++)
  {
    fprintf (fp2, "  { 0x%02X, 0x%02X, 0x%02X, 0x%02X }%c\n",
              ram[p], ram[p+1], ram[p+2], ram[p+3],
              (i<7 ? ',' : ' '));
    p += 4;
  }
  fprintf (fp2, "};\n\n");

  fclose (fp2);

#define WIDTH 16

  // dump title data to .ASM
  fp = fopen ("c/src/kl/kl.scr", "rb");
  if (fp)
  {
    fp2 = fopen ("kl_scr.asm", "wt");
    if (fp2)
    {
      fprintf (fp2, ";\n; screen memory\n;\n");
      fprintf (fp2, "vram:\n");
      for (unsigned line=0; line<192; line++)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;
          
          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fprintf (fp2, ";\n; attribute memory\n;\n");
      fprintf (fp2, "aram:\n");
      for (unsigned line=0; line<192; line+=8)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;

          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fclose (fp2);
    }
    fclose (fp);
  }

  // dump title data to .ASM
  fp = fopen ("c/src/a8/alien8.scr", "rb");
  if (fp)
  {
    fp2 = fopen ("a8_scr.asm", "wt");
    if (fp2)
    {
      fprintf (fp2, ";\n; screen memory\n;\n");
      fprintf (fp2, "vram:\n");
      for (unsigned line=0; line<192; line++)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;
          
          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fprintf (fp2, ";\n; attribute memory\n;\n");
      fprintf (fp2, "aram:\n");
      for (unsigned line=0; line<192; line+=8)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;

          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fclose (fp2);
    }
    fclose (fp);
  }

  // dump title data to .ASM
  fp = fopen ("c/src/pg/pentagram.scr", "rb");
  if (fp)
  {
    fp2 = fopen ("pg_scr.asm", "wt");
    if (fp2)
    {
      fprintf (fp2, ";\n; screen memory\n;\n");
      fprintf (fp2, "vram:\n");
      for (unsigned line=0; line<192; line++)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;
          
          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fprintf (fp2, ";\n; attribute memory\n;\n");
      fprintf (fp2, "aram:\n");
      for (unsigned line=0; line<192; line+=8)
      {
        for (unsigned byte=0; byte<32; byte++)
        {
          uint8_t data8;

          fread (&data8, 1, 1, fp);
          if (byte%WIDTH == 0) fprintf (fp2, "    .db ");
          fprintf (fp2, "0x%02X", data8);
          if (byte%WIDTH < WIDTH-1) fprintf (fp2, ", "); else fprintf (fp2, "\n");
        }
      }
      fclose (fp2);
    }
    fclose (fp);
  }

#else

#ifdef DO_ASCII
  fp2 = fopen ("knightlore.asc", "wb");
  for (unsigned p=0x6108; p<0xd8f3; p++)
  {
    unsigned char c = ram[p] & 0x7f;
    if (c < 40)
      ascii[p] = to_ascii[c];
    else
      ascii[p] = ' ';
  }
	// write the relevant areas
	fwrite (&ascii[0x6108], 0xd8f3-0x6108, 1, fp);
  fclose (fp2);
#endif

#ifdef DO_PARSE_MAP
  // parse the map

  unsigned p = 0x6248;
  fprintf (stdout, "X,Y,Z=%03d,%03d,%03d\n",
            ram[p+0], ram[p+1], ram[p+2]);

  p = 0x6251;
  int n = 0;
  while (1)
  {
    fprintf (stdout, "id=%03d\n", ram[p+0]);
    fprintf (stdout, " byte count =%03d\n", ram[p+1]);
    fprintf (stdout, " size=%02d\n", ram[p+2]>>3);
    fprintf (stdout, " attributes =%02d\n", ram[p+2]&0x07);

    unsigned b;
    for (b=0; ram[p+3+b] != 0xff; b++)
    {
      fprintf (stdout, " BG=%03d\n", ram[p+3+b]);
      if (4+b == 1+ram[p+1])
      break;
    }
    if (4+b != 1+ram[p+1])
    {
      unsigned f;
      for (f=0; ; f++)
      {
        fprintf (stdout, " block=%02d\n", ram[p+4+b+f]>>3);
        unsigned count = (ram[p+4+b+f]&0x07)+1;
        fprintf (stdout, " count=%02d\n", count);
        unsigned c;
        for (c=0; c<count; c++, f++)
        {
          unsigned xyz = ram[p+5+b+f];
          fprintf (stdout, "  x,y,z=%02d,%02d,%02d\n",
                    xyz&0x07, (xyz>>3)&0x07, (xyz>>6)&0x03);
        }
        if (5+b+f == 1+ram[p+1])
          break;
      }
    }
    p += 1 + ram[p+1];

    if (++n == 128)
      break;
  }
#endif

#ifdef DO_GA
	// sort the list of sprite graphics addresses
	unsigned short ga[256];
	unsigned short iga = 0;
	unsigned nga = (0x728A - 0x7112) / 2;
	fprintf (stdout, "nga=%d\n", nga);
	for (unsigned i=0; i<nga; i++)
	{
		unsigned short a = ram[0x7112+i*2+1];
		a = (a<<8) | ram[0x7112+i*2];
		
		// now put it in place
		unsigned j;
		for (j=0; j<iga; j++)
			if (a <= ga[j])
				break;
		if (i > 0 && a == ga[j]) continue;
		
		// move up
		for (unsigned k=iga+1; k>j; k--)
			ga[k] = ga[k-1];
		ga[j] = a;
		iga++;
	}
	
	for (unsigned i=0; i<iga; i++)
		fprintf (stderr, "$%04X\n", ga[i]);
#endif

	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 320, 192, 0, 0);

  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 7, 1);


#ifdef DO_FONT
	clear_bitmap (screen);
  for (unsigned c=0; c<40; c++)
  {
      plot_character (c, (c%16)*16, (c/16)*16, 7);
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

	clear_bitmap (screen);
	const char *msg[] = 
	{
	  "THIS IS THE FONT FROM A MYSTERY GAME",
	  "FROM A Z80 PLATFORM",
	  "THAT I AM CURRENTLY EVALUATING FOR",
	  "A POSSIBLE PORT TO",
	  "THE COLOR COMPUTER 3",
	  ""
	};

  for (unsigned m=0; *msg[m]; m++)
  {
    for (unsigned c=0; msg[m][c]; c++)
      plot_ascii_character (msg[m][c], (320-strlen(msg[m])*8)/2 + c*8, 16+m*16, m+2);
  }	
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  

#endif


#ifdef DO_SPRITE_DATA
	unsigned p = 0x728C;
  unsigned s = 0;
  for (s=0; p<0xAE98; s++)
  {
    if (s%16 == 0)
	    clear_bitmap (screen);

    // there's a gap in the sprite data
    if (p == 0x7D98)
      p += 12;

    p = plot_sprite_data (s, 0, p, (s%8)*40, ((s%16)/8)*64, 3, w, h);

    if (s%16 == 15)
    {
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

#ifdef DO_SPRITE_TABLE
  t = 0x7112;
  unsigned s = 0;
  for (s=0; t<0x728A; s++, t+=2)
  {
    if (s%16 == 0)
	    clear_bitmap (screen);

    plot_sprite (s, 0, (s%8)*40, ((s%16)/8)*64, 3, w, h);

    if (s%16 == 15)
    {
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
#endif

#ifdef DO_BLOCK_DATA
  t = 0x6C0B;
  unsigned e = 0;
  for (e=0; t<0x6CE2; e++)
  {
    unsigned n = 0;
    unsigned sw, sh, iw=0, ih=0;
        
    if (e%8 == 0)
      clear_bitmap (screen);
    while (ram[t] != 0)    
    {
      unsigned s = ram[t++];
      unsigned w = ram[t++];
      unsigned h = ram[t++];
      unsigned z = ram[t++];
      unsigned f = ram[t++];
      unsigned o = ram[t++];
      
      plot_sprite (s, f, (e%8)*40, ih, 3, sw, sh);
      ih += sh;
    }
    t++;

    if (e%8 == 7)
    {    
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

#ifdef DO_BG_DATA
  t = 0x6D12;
  unsigned e = 0;
  for (e=0; t<0x6FF2; e++)
  {
    unsigned n = 0;
    unsigned sw, sh, iw=0, ih=0;
    
    //if (e%8 == 0)
      clear_bitmap (screen);
    while (ram[t] != 0)    
    {
      unsigned s = ram[t++];
      unsigned x = ram[t++];
      unsigned y = ram[t++];
      unsigned z = ram[t++];
      unsigned w = ram[t++];
      unsigned d = ram[t++];
      unsigned h = ram[t++];
      unsigned f = ram[t++];
      
      plot_sprite (s, f, (e%8)*40+iw, 0, 3, sw, sh);
      iw += sw; ih += sh;
    }
    t++;

    //if (e%8 == 7)
    {    
      while (!key[KEY_ESC]);	  
    	while (key[KEY_ESC]);	  
    }
  }
  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
#endif

  fclose (fpdbg);
  
  allegro_exit ();

#endif // DO_C_DATA

  //fprintf (stdout, "w=%d\n", widest);
  //fprintf (stdout, "h=%d\n", highest);
}

END_OF_MAIN();
