#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>

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
      printf ("%03d (%2dx%2d) != (%2dx%2d) %c %c %c\n",
              s, w_zx, h_zx, w_cpc, h_cpc,
              (2*w_zx != w_cpc ? 'W' : ' '),
              (h_zx != h_cpc ? 'H' : ' '),
              (w_cpc & 1 ? '*' : ' '));
    
    a_zx += 2;
    a_cpc += 2;
    s++;
  }
  
  
  fprintf (stderr, "Done!\n");
}
