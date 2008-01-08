#include <stdio.h>
#include <stdlib.h>

#define TUTANKHM

typedef struct
{
  char          name[16];
  unsigned int  base_addr;
  unsigned int  length;

} ROM_INFO;

#ifdef TUTANKHM
#define SET_NAME  "tutankhm"
#define SUBDIR		SET_NAME
#endif

ROM_INFO rom_info[] =
{
	{ "h1.bin",     0x0a000, 0x1000 },
	{ "h2.bin",     0x0b000, 0x1000 },
	{ "h3.bin",     0x0c000, 0x1000 },
	{ "h4.bin",     0x0d000, 0x1000 },
	{ "h5.bin",     0x0e000, 0x1000 },
	{ "h6.bin",    	0x0f000, 0x1000 },
	{ "j1.bin",     0x10000, 0x1000 },
	{ "j2.bin",    	0x11000, 0x1000 },
	{ "j3.bin",     0x12000, 0x1000 },
	{ "j4.bin",    	0x13000, 0x1000 },
	{ "j5.bin",     0x14000, 0x1000 },
	{ "j6.bin",     0x15000, 0x1000 },
	{ "j7.bin",     0x16000, 0x1000 },
	{ "j8.bin",     0x17000, 0x1000 },
	{ "j9.bin",     0x18000, 0x1000 },
  { "", 0, 0 }
};

int main (int argc, char *argv[])
{
  FILE *fp = fopen (SUBDIR "/" SET_NAME "_roms.bin", "wb");
  if (!fp) exit (0);

  //FILE *fp2 = fopen (SUBDIR "/" SET_NAME "_roms_x4.bin", "wb");
  FILE *fp2 = fopen (SUBDIR "/" SET_NAME "_roms_x2.bin", "wb");
  if (!fp2) exit (0);

  int r=0;
  unsigned int addr = 0;

  while (*rom_info[r].name)
  {
    int i;

    // pad empty spaces with 0x00
    if (addr < rom_info[r].base_addr)
      for (i=0; i<rom_info[r].base_addr-addr; i++)
      {
        fwrite ("", 1, 1, fp);
        fwrite ("", 1, 1, fp2);
        fwrite ("", 1, 1, fp2);
        //fwrite ("", 1, 1, fp2);
        //fwrite ("", 1, 1, fp2);
      }

    printf ("%s\n", rom_info[r].name);

    // append rom to image file
    char rom_buf[1024];
    char rom_name[64];
    sprintf (rom_name, SUBDIR "/%s", rom_info[r].name);
    FILE *fpi = fopen (rom_name, "rb");
    do
    {
      int bytes = fread (rom_buf, 1, 1024, fpi);
      if (bytes > 0)
      {
        fwrite (rom_buf, 1, bytes, fp);

        int j;
        for (j=0; j<bytes; j++)
        {
          fwrite (&rom_buf[j], 1, 1, fp2);
          fwrite (&rom_buf[j], 1, 1, fp2);
          //fwrite (&rom_buf[j], 1, 1, fp2);
          //fwrite (&rom_buf[j], 1, 1, fp2);
        }
      }

    } while (!feof (fpi));
    fclose (fpi);

    addr = rom_info[r].base_addr + rom_info[r].length;
    r = r + 1;
  }

  fclose (fp);
  fclose (fp2);
}

