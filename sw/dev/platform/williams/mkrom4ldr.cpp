#include <stdio.h>
#include <stdlib.h>

#define DEFENDER

typedef struct
{
  char          name[16];
  unsigned int  base_addr;
  unsigned int  length;

} ROM_INFO;

#ifdef DEFENDER
#define SET_NAME  "defender"
#define SUBDIR    SET_NAME
#endif

ROM_INFO rom_info[] =
{
	{ "defend.1",     0x0d000, 0x0800 },
	{ "defend.4",     0x0d800, 0x0800 },
	{ "defend.2",     0x0e000, 0x1000 },
	{ "defend.3",     0x0f000, 0x1000 },
	{ "defend.9",     0x10000, 0x0800 },
	{ "defend.12",    0x10800, 0x0800 },
	{ "defend.8",     0x11000, 0x0800 },
	{ "defend.11",    0x11800, 0x0800 },
	{ "defend.7",     0x12000, 0x0800 },
	{ "defend.10",    0x12800, 0x0800 },
	{ "defend.6",     0x16000, 0x0800 },
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

