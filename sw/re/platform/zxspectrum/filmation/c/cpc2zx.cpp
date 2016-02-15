#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>

#include <allegro.h>

#define ALLEGRO_FULL_VERSION  ((ALLEGRO_VERSION << 4)|(ALLEGRO_SUB_VERSION))
#if ALLEGRO_FULL_VERSION < 0x42
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre (s, f, str, w, h, c);
#else
  #define SS_TEXTOUT_CENTRE(s,f,str,w,h,c) \
    textout_centre_ex(s, f, str, w, h, c, 0);
#endif

//#define DO_SPRITE_GFX

uint8_t ram_zx[0x10000];
uint8_t ram_cpc[0x10000];

int main (int argc, char *argv[])
{
	struct stat	    fs;
	int					    fd;

  FILE *fpZx = fopen ("../knightlore.bin", "rb");
	if (!fpZx)
		exit (0);
	fd = fileno (fpZx);
	if (fstat	(fd, &fs))
		exit (0);
  fread (&ram_zx[0x6108], sizeof(uint8_t), fs.st_size, fpZx);
  fclose (fpZx);

  FILE *fpCpc = fopen ("../../../cpc/kl_cpc.bin", "rb");
	if (!fpCpc)
		exit (0);
	fd = fileno (fpCpc);
	if (fstat	(fd, &fs))
		exit (0);
  fread (&ram_cpc[0x0000], sizeof(uint8_t), fs.st_size, fpCpc);
  fclose (fpCpc);

  unsigned a_zx = 0x6251;
  unsigned a_cpc = 0x33dd;
  
  //compare location tables
  printf ("location_tbl:\n");
  while (a_zx < 0x6bd1)
  {
    if (ram_zx[a_zx] != ram_cpc[a_cpc])
    {      
      printf ("@$%04X[$%02X] != @$%04X[$%02X]\n",
              a_zx, ram_zx[a_zx], a_cpc, ram_cpc[a_cpc]);
    }
                
    a_zx++;
    a_cpc++;
  }

  // compare background object tables

  static char *bg_obj_str[] =
  {
    "arch_n", 
    "arch_e", 
    "arch_s", 
    "arch_w", 
    "tree_arch_n", 
    "tree_arch_e", 
    "tree_arch_s", 
    "tree_arch_w", 
    "gate_n", 
    "gate_e", 
    "gate_s", 
    "gate_w", 
    "wall_size_1", 
    "wall_size_2", 
    "wall_size_3", 
    "tree_room_size_1", 
    "tree_filler_w", 
    "tree_filler_n", 
    "wizard", 
    "cauldron", 
    "high_arch_e", 
    "high_arch_s", 
    "high_arch_e_base", 
    "high_arch_s_base"
  };

  printf ("background_type_tbl:\n");
  a_zx = 0x6ce2;
  a_cpc = 0x3e6e;
  unsigned s = 0;
  while (a_zx < 0x6d12)
  {
    unsigned p_zx = ram_zx[a_zx+1];
    p_zx = (p_zx << 8) + ram_zx[a_zx];
    unsigned p_cpc = ram_cpc[a_cpc+1];
    p_cpc = (p_cpc << 8) + ram_cpc[a_cpc];
    
    unsigned l = 0;
    while (ram_zx[p_zx] != 0)
    {
      static char *byte_str[] = 
      {
        "sprite", "x", "y", "z", "w", "d", "h", "flags"
      };
      for (unsigned i=0; i<8; i++)
      {
        if (ram_zx[p_zx+i] != ram_cpc[p_cpc+i])
          printf ("%20.20s %1d %8.8s @$%04X[$%02X] != @$%04X[$%02X]\n",
                  bg_obj_str[s], l, byte_str[i], a_zx, 
                  ram_zx[p_zx+i], a_cpc, ram_cpc[p_cpc+i]);
      }
      p_zx += 8;
      p_cpc += 8;
      l++;
    }
    
    a_zx += 2;
    a_cpc += 2;
    s++;
  }
  
  // compare foreground object tables

  static char *fg_obj_str[] =
  {
    "block",
    "fire",
    "ball_ud_y",
    "rock",
    "gargoyle",
    "spike",
    "chest",
    "table",
    "guard_ew",
    "ghost",
    "fire_ns",
    "block_high",
    "ball_ud_xy",
    "guard_square",
    "block_ew",
    "block_ns",
    "moveable_block",
    "spike_high",
    "spike_ball_fall",
    "spike_ball_high_fall",
    "fire_ew",
    "dropping_block",
    "collapsing_block",
    "ball_bounce",
    "ball_ud",
    "repel_spell",
    "gate_ud_1",
    "gate_ud_2",
    "ball_ud_x",
  };

  printf ("foreground_type_tbl:\n");
  a_zx = 0x6bd1;
  a_cpc = 0x3d5d;
  s = 0;
  while (a_zx < 0x6c0b)
  {
    unsigned p_zx = ram_zx[a_zx+1];
    p_zx = (p_zx << 8) + ram_zx[a_zx];
    unsigned p_cpc = ram_cpc[a_cpc+1];
    p_cpc = (p_cpc << 8) + ram_cpc[a_cpc];
    
    unsigned l = 0;
    while (ram_zx[p_zx] != 0)
    {
      static char *byte_str[] = 
      {
        "sprite", "w", "d", "h", "flags", "offsets"
      };
      for (unsigned i=0; i<6; i++)
      {
        if (ram_zx[p_zx+i] != ram_cpc[p_cpc+i])
          printf ("%20.20s %1d %8.8s @$%04X[$%02X] != @$%04X[$%02X]\n",
                  fg_obj_str[s], l, byte_str[i], a_zx, 
                  ram_zx[p_zx+i], a_cpc, ram_cpc[p_cpc+i]);
      }
      p_zx += 6;
      p_cpc += 6;
      l++;
    }
    
    a_zx += 2;
    a_cpc += 2;
    s++;
  }
  
  // now compare sprites
  printf ("sprite_tbl:\n");
  a_zx = 0x7112;
  a_cpc = 0x429e;
  s = 0;

  unsigned diff[104];
  unsigned n_diff = 0;
    
  while (a_zx < 0x728a)
  {
    unsigned p_zx = ram_zx[a_zx+1];
    p_zx = (p_zx << 8) + ram_zx[a_zx];
    unsigned p_cpc = ram_cpc[a_cpc+1];
    p_cpc = (p_cpc << 8) + ram_cpc[a_cpc];

    uint8_t w_zx = ram_zx[p_zx] & 0x3f;
    uint8_t h_zx = ram_zx[p_zx+1];

    uint8_t w_cpc = ram_cpc[p_cpc] & 0x3f;
    uint8_t h_cpc = ram_cpc[p_cpc+1];

    if (2*w_zx != w_cpc || h_zx != h_cpc)
    {
      unsigned i;
      for (i=0; i<n_diff; i++)
        if (diff[i] == p_zx)
          break;
      if (n_diff == 0 || i == n_diff)
      {
        diff[n_diff++] = p_zx;      
        printf ("@$%04X %03d/$%02X (%2dx%2d) != (%2dx%2d) %c %c %c\n",
                p_zx, s, s, w_zx, h_zx, w_cpc, h_cpc,
                (2*w_zx != w_cpc ? 'W' : ' '),
                (h_zx != h_cpc ? 'H' : ' '),
                (w_cpc & 1 ? '*' : ' '));
                  
        if (0 && h_zx > h_cpc)
        {
          printf ("h_zx < h_cpc:\n");
          printf ("- top\n");
          for (unsigned i=0; i<w_zx; i++)
            printf ("$%02X ", ram_zx[p_zx+2+i]);
          printf ("\n");
          printf ("- bottom\n");
          for (unsigned i=0; i<w_zx; i++)
            printf ("$%02X ", ram_zx[p_zx+2+w_zx*(h_zx-1)+i]);
          printf ("\n");
        }
      }
    }
    
    a_zx += 2;
    a_cpc += 2;
    s++;
  }

  // now write data out to a C file
  
  FILE *fp2 = fopen ("data2.c", "wt");
  if (!fp2)
    exit (0);
      
  typedef struct
  {
    char        label[32];
    uint16_t    addr;
    
  } BLKTYP_T, *PBLKTYP_T;

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
  
  uint16_t p = 0x3e6e;
  unsigned n;
  for (n=0; p<0x3e9e; n++, p+=2)
  {
    bgtyp[n].addr = ram_cpc[p+1];
    bgtyp[n].addr = (bgtyp[n].addr<<8) | ram_cpc[p];
  }
  while (p < 0x417e)
  {
    unsigned i;
    
    // find address
    for (i=0; i<n; i++)
      if (p == bgtyp[i].addr)
        break;
    if (i == n)
      fprintf (stderr, "ERR: bg_type addr=$%04X\n", p);

    // do table entry
    fprintf (fp2, "static const uint8_t %s[] = \n{\n", bgtyp[i].label);
    do
    {
      fprintf (fp2, "  0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X, 0x%02X,\n",
                ram_cpc[p], ram_cpc[p+1], ram_cpc[p+2], ram_cpc[p+3], 
                ram_cpc[p+4], ram_cpc[p+5], ram_cpc[p+6], ram_cpc[p+7]);
      p += 8;
      
    } while (ram_cpc[p] != 0);
    fprintf (fp2, "  0");
    p++;
    fprintf (fp2,"\n};\n\n");
  }

  fprintf (fp2, "uint8_t const *cpc_background_type_tbl[] __FORCE_RODATA__ = \n{\n");
  for (unsigned i=0; i<n; i++)
  {
    fprintf (fp2, "  %s%s\n", bgtyp[i].label,
      (i<n-1 ? "," : ""));
  }
  fprintf (fp2, "};\n\n");

  // create table of sprite addresses
  uint16_t sprite_a[132];
  unsigned sprite_n = 0;
  p = 0x4424;
  while (p < 0x7ffb)
  {
    unsigned w = ram_cpc[p+0] & 0x3f;
    unsigned h = ram_cpc[p+1];
    
    //fprintf (stderr, "spr_%03d=$%04X\n", sprite_n, p);
    sprite_a[sprite_n++] = p;

    if (w==0 && h==0)
    {
      p += 2;
      continue;
    }

    p += 3 + w*h;    
  }
  //fprintf (stderr, "sprite_n=%d\n", sprite_n);

  // sprite_tbl
  fprintf (fp2, "const uint8_t *cpc_sprite_tbl[] __FORCE_RODATA__ =\n{\n");
  n = 0;
  for (p=0x429e; p<0x4422; p+=2, n++)
  {
    char label[16];

    uint16_t a = ram_cpc[p+1];
    a = (a<<8) | ram_cpc[p];
    if (a == 0x4422)
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
  fprintf (fp2, "static uint8_t spr_nul[] __FORCE_RODATA__ =\n{\n  0, 0\n};\n\n");
  p = 0x4424;
  sprite_n = 0;
  while (p < 0x7ffb)
  {
    unsigned w = ram_cpc[p+0] & 0x3f;
    unsigned h = ram_cpc[p+1];
    unsigned f = ram_cpc[p+2];
    
    if (ram_cpc[p+0] & 0xc0)
      fprintf (stderr, "*** WARNING sprite %03d flipped ($%02X)\n",
                sprite_n, ram_cpc[p+0]);
    fprintf (fp2, "static uint8_t spr_%03d[] __FORCE_RODATA__ =\n{\n  %d, %d, %d,\n",
              sprite_n++, w, h, f);
    unsigned i;
    p += 3;
    for (unsigned i=0; i<w*h; i++, p++)
    {
      if ((i%8)==0) fprintf (fp2, "  ");
      fprintf (fp2, "0x%02X, ", ram_cpc[p]);
      if ((i%8)==7) fprintf (fp2, "\n");
    }
    fprintf (fp2, "\n};\n\n");
  }

  fclose (fp2);  
  fprintf (stderr, "Done!\n");

#ifdef DO_SPRITE_GFX
  
	allegro_init ();
	install_keyboard ();

	set_color_depth (8);
	set_gfx_mode (GFX_AUTODETECT_WINDOWED, 640, 480, 0, 0);

  PALETTE pal;
  for (int c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 7, 1);

  a_cpc = 0x429e;
  s = 0;
  unsigned x=0;
  unsigned y=0;
  unsigned highest;
  
  while (a_cpc < 0x4422)
  {
    unsigned p_cpc = ram_cpc[a_cpc+1];
    p_cpc = (p_cpc << 8) + ram_cpc[a_cpc];

    uint8_t w_cpc = ram_cpc[p_cpc] & 0x3f;
    uint8_t h_cpc = ram_cpc[p_cpc+1];

    if ((s%16) == 0)
    {
      x = 0;
      highest = 0;
    }

    p_cpc += 3;
    for (unsigned yb=0; yb<h_cpc; yb++)    
    {
      for (unsigned xb=0; xb<w_cpc; xb++)
      {
        uint8_t d = ram_cpc[p_cpc+yb*w_cpc+xb];
        for (unsigned b=0; b<8; b+=2)
        {
          static unsigned lu[] = { 0, 4, 5, 0 };
          unsigned c = ((d&0x80)>>6)|((d&0x08)>>3);
          putpixel (screen, x+xb*4+b/2, y+(h_cpc-1-yb), lu[c]);
          d <<= 1;
        }
      }
    }
    if (h_cpc > highest)
      highest = h_cpc;
    
    x += w_cpc*4 + 4;
    
    if ((s%16) == 15)
      y += highest + 4;
      
    a_cpc += 2;
    s++;
  }

  while (!key[KEY_ESC]);	  
	while (key[KEY_ESC]);	  
  
  allegro_exit ();
  
#endif  
}

END_OF_MAIN();
