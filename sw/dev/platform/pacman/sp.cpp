#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <allegro.h>

typedef unsigned char uchar;

#define MEM_SIZE			(64*1024)
#define ROM_SIZE      (4*0x1000)
#define VRAM_BASE			0x4000
#define VRAM_SIZE			0x0400
#define ATTR_BASE			0x4400
#define HW_SPRITES			8

#define TILE_SIZE			    0x1000
#define SPRITE_SIZE			  0x1000
#define PAL_PROM_SIZE		  0x20
#define CLUT_SIZE			    0x400

#define WIDTH_PIXELS		224
#define HEIGHT_PIXELS		288
#define WIDTH_BYTES			(WIDTH_PIXELS>>3)
#define HEIGHT_BYTES		(HEIGHT_PIXELS>>3)
#define COLOUR(i)       	(i)
#define YPOS(i)         	(i)

#define NUM_TILES			  256
#define NUM_SPRITES			64

uchar mem[MEM_SIZE];
unsigned char tiles[TILE_SIZE];
unsigned char sprites[SPRITE_SIZE];
uchar pal_prom[PAL_PROM_SIZE];
uchar clut_prom[CLUT_SIZE];

unsigned char tiles_rot90[TILE_SIZE];
unsigned char sprites_rot90[SPRITE_SIZE];

char *int2bin (int value, int bits)
{
  static char bin[32];
  int i;

  for (i=0; i<bits; i++)
    bin[i] = ((value & (1<<(bits-1-i))) ? '1' : '0');
  bin[i] = '\0';

  return (bin);
}
	
int main (int arc, char *argv[])
{
    FILE *fp;

	// cpu memory map
	fp = fopen ("pacman.mem", "rb");
	fread (mem, sizeof(unsigned char), MEM_SIZE, fp);
	fclose (fp);

	// read the roms (over the memory map)
	static char *rom_file[] = 
	{
		"pacman.6e",	"pacman.6f",	"pacman.6h", "pacman.6j"
	};
	#define NUM_ROMS 4
	for (int i=0; i<NUM_ROMS; i++)
	{
		if (!(fp = fopen (rom_file[i], "rb")))
			continue;
		fread (&mem[i*0x1000], sizeof(unsigned char), 0x1000, fp);
		fclose (fp);
	}
	
	// tiles 
	fp = fopen ("pacman.5e", "rb");
	fread (&tiles[0], sizeof(unsigned char), TILE_SIZE, fp);
	fclose (fp);

	// sprites
	fp = fopen ("pacman.5f", "rb");
	fread (&sprites[0], sizeof(unsigned char), SPRITE_SIZE, fp);
	fclose (fp);

	// read the proms
	fp = fopen ("82s123.7f", "rb");
	fread (pal_prom, sizeof(unsigned char), PAL_PROM_SIZE, fp);
	fclose (fp);
	fp = fopen ("82s126.4a", "rb");
	fread (clut_prom, sizeof(unsigned char), CLUT_SIZE, fp);
	fclose (fp);

    // write the ROM
	fp = fopen ("pacman_rom.bin", "wb");
	if (!fp) exit (0);
	fwrite (mem, sizeof(unsigned char), ROM_SIZE, fp);
	fclose (fp);

    // write the VRAM
	fp = fopen ("pacman_vram.bin", "wb");
	if (!fp) exit (0);
	fwrite (&mem[VRAM_BASE], sizeof(unsigned char), VRAM_SIZE, fp);
	fclose (fp);
	
    // write the CRAM
	fp = fopen ("pacman_cram.bin", "wb");
	if (!fp) exit (0);
	fwrite (&mem[ATTR_BASE], sizeof(unsigned char), VRAM_SIZE, fp);
	fclose (fp);
	
	// convert the tilemaps (8x8)
    static uchar tile_poff[] = { 0, 4 };
    static uchar tile_xoff[] = { 56, 48, 40, 32, 24, 16, 8, 0 };
    static uchar tile_yoff[] = { 64, 65, 66, 67, 0, 1, 2, 3 }; 
	for (int t=0; t<NUM_TILES; t++)
	{
		for (int y=0; y<8; y++)
		{
			uchar tdat = 0;
			
			for (int x=0; x<8; x++)
			{
				uchar pel = 0;
                for (int p=0; p<2; p++)
                {
                    int bit = tile_poff[p]+tile_xoff[x]+tile_yoff[y^0x03];
                    pel |= ((tiles[t*16+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
                }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) tiles_rot90[t*16+y*2+(x>>2)] = tdat;
			}
		}
	}
	fp = fopen ("tiles_rot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (tiles_rot90, sizeof(unsigned char), TILE_SIZE, fp);
	fclose (fp);

	// convert the sprites (16x16)

	FILE *fpSpr[4];
	for (int i=0; i<4; i++)
	{
		char sprFile[64];
		sprintf (sprFile, "sprite%d.bin", i);
		fpSpr[i] = fopen (sprFile, "wb");
	}

  static int sprite_poff[] = { 0, 4 };
	static int sprite_xoff[] = { 312, 304, 296, 288, 280, 272, 264, 256, 56, 48, 40, 32, 24, 16, 8, 0 }; 
	static int sprite_yoff[] = { 64, 65, 66, 67, 128, 129, 130, 131, 192, 193, 194, 195, 0, 1, 2, 3 }; 
	for (int t=0; t<NUM_SPRITES; t++)
	{
		for (int y=0; y<16; y++)
		{
			uchar tdat = 0;
			
			for (int x=0; x<16; x++)
			{
				uchar pel = 0;
        for (int p=0; p<2; p++)
        {
            int bit = sprite_poff[p]+sprite_xoff[x]+sprite_yoff[y^0x03];
            pel |= ((sprites[t*64+(bit>>3)] >> (bit & 0x07)) & 0x01) << (1-p);
        }
			
				tdat = (tdat << 2) | pel;
				if ((x % 4) == 3) 
        {
            sprites_rot90[t*64+y*4+(x>>2)] = tdat;
            fwrite (&tdat, 1, 1, fpSpr[x>>2]);
        }
			}
		}
	}
	fp = fopen ("sprites_rot90.bin", "wb");
	if (!fp) exit (0);
	fwrite (sprites_rot90, sizeof(unsigned char), SPRITE_SIZE, fp);
	fclose (fp);

	for (int i=0; i<4; i++)
		fclose (fpSpr[i]);

  	allegro_init ();
  	install_keyboard ();

  	set_color_depth (8);
  	set_gfx_mode (GFX_AUTODETECT_WINDOWED, WIDTH_PIXELS, HEIGHT_PIXELS, 0, 0);

  	// set the palette
    FILE *fppal = fopen ("pal.txt", "wt");
  	PALETTE pal;
  	for (int c=0; c<PAL_PROM_SIZE; c++)
  	{
      pal[c].r = ((pal_prom[c] & (1<<0) ? 0x21 : 0x00) + 
      			  (pal_prom[c] & (1<<1) ? 0x47 : 0x00) +
      			  (pal_prom[c] & (1<<2) ? 0x97 : 0x00)) >> 2;
      pal[c].g = ((pal_prom[c] & (1<<3) ? 0x21 : 0x00) + 
      			  (pal_prom[c] & (1<<4) ? 0x47 : 0x00) +
      			  (pal_prom[c] & (1<<5) ? 0x97 : 0x00)) >> 2;
      pal[c].b = ((pal_prom[c] & (1<<6) ? 0x47 : 0x00) + 
      			  (pal_prom[c] & (1<<7) ? 0x97 : 0x00)) >> 2;

      if (!(pal[c].r == 0 && pal[c].g == 0 && pal[c].b == 0))
      {
        char r[32], g[32], b[32];
        //fprintf (fppal, "%d: $%02X $%02X $%02X\n", c, pal[c].r, pal[c].g, pal[c].b);
        strcpy (r, int2bin(pal[c].r,6)); strcpy (g, int2bin(pal[c].g,6)); strcpy (b, int2bin(pal[c].b,6));
        fprintf (fppal, "%d => (0=>\"%s\", 1=>\"%s\", 2=>\"%s\"),\n", c, r, g, b);
      }
    }

    fprintf (fppal, "\nCLUT Entries\n");
    for (int l=0; l<32; l++)
    {
      if (!(clut_prom[l*4] == 0 && clut_prom[l*4+1] == 0 && clut_prom[l*4+2] == 0 && clut_prom[l*4+3] == 0))
      {
        //fprintf (fppal, "%d: $%02X $%02X $%02X $%02X\n", l, 
        //          clut_prom[l*4], 
        //          clut_prom[l*4+1], 
        //          clut_prom[l*4+2], 
        //          clut_prom[l*4+3]);
        fprintf (fppal, "%d => (0=>X\"%1X\", 1=>X\"%1X\", 2=>X\"%1X\", 3=>X\"%1X\"),\n", l, 
                  clut_prom[l*4], 
                  clut_prom[l*4+1], 
                  clut_prom[l*4+2], 
                  clut_prom[l*4+3]);
        }
    }

    fclose (fppal);
  	set_palette_range (pal, 0, 32, 1);

	/* show the screen */

	for (int y=0; y<HEIGHT_BYTES; y++)
	{
		for (int x=0; x<WIDTH_BYTES; x++)
		{
			int vram_addr;
			if (y < 2)
				vram_addr = 0x3C2 + (y*32) + WIDTH_BYTES-1-x;
			else
			if (y > (HEIGHT_BYTES-2-1))
				vram_addr = 0x02 + (y-(HEIGHT_BYTES-2))*32 + WIDTH_BYTES-1-x;
			else
				vram_addr = 0x40 + (WIDTH_BYTES-1-x)*0x20 + (y-2);
			int c = mem[VRAM_BASE+vram_addr];
			int attr = mem[ATTR_BASE+vram_addr]; // & 0x0f;

			for (int ty=0; ty<8; ty++)
			{
				for (int tx=0; tx<8; tx++)
				{
					uchar pel = tiles_rot90[c*16+ty*2+(tx>>2)];
					pel = (pel >> ((3-(tx&0x03))<<1)) & 0x03;
                    pel = ((pel >> 1) & 0x01) | ((pel << 1) & 0x02);
					putpixel (screen, x*8+tx, y*8+ty, clut_prom[attr*4+pel]);
				}
			}
		}
	}

	/* show some sprites */

  //  note: this will not show reasonable results	
  //  because the sprite registers are write-only!!!

	for (int s=0; s<HW_SPRITES; s++)
	{
		#define SPRITE_REG_BASE			0x4ff0
		
		// sprites priority encoding
		int n = (HW_SPRITES-1-s);
		//int sx = mem[SPRITE_XY_BASE+(n*2)+0];
		//int sy = mem[SPRITE_XY_BASE+(n*2)+1];
		/* we can't read the sprite co-ordinates back */
		int sx = 0;
		int sy = (n+8) * 16;
		int code = mem[SPRITE_REG_BASE+(n*2)+0] >> 2;
		int xflip = (mem[SPRITE_REG_BASE+(n*2)+0] & (1<<1)) != 0;
		int yflip = (mem[SPRITE_REG_BASE+(n*2)+0] & (1<<0)) != 0;
		int clr = mem[SPRITE_REG_BASE+(n*2)+1];
		
		for (int ty=0; ty<16; ty++)
		{
			for (int tx=0; tx<16; tx++)
			{
				int xoff = (xflip ? 15-tx : tx);
				int yoff = (yflip ? 15-ty : ty);
				
				uchar pel = sprites_rot90[code*64+ty*4+(tx>>2)];
				pel = (pel >> ((3-(tx&0x03))<<1)) & 0x03;
                pel = ((pel >> 1) & 0x01) | ((pel << 1) & 0x02);
				putpixel (screen, sx+xoff, YPOS(sy)+yoff, clut_prom[clr*4+pel]);
			}
		}
	}
	
    while (!key[KEY_ESC])
    	;	  
}

END_OF_MAIN();
