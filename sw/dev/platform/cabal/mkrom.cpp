#include <stdio.h>
#include <stdlib.h>

#define SET_NAME    "CABAL"
#define SUB_DIR     SET_NAME "/"

unsigned char rom[4*0x10000];

int rd_oe_rom (unsigned char *base, char *filename)
{
  FILE *fp = fopen (filename, "rb");

  if (!fp)
    return (0);

  while (!feof (fp))
  {
    fread (base, 1, 1, fp);
    base += 2;
  }

  fclose (fp);
  return (1);
}

int main (int argc, char *argv[])
{
  rd_oe_rom (&rom[0x00000], SUB_DIR "h7_512.bin");
  rd_oe_rom (&rom[0x00001], SUB_DIR "h6_512.bin");
  rd_oe_rom (&rom[0x20000], SUB_DIR "k7_512.bin");
  rd_oe_rom (&rom[0x20001], SUB_DIR "k6_512.bin");
  
  FILE *fp = fopen ("cabal_rom.bin", "wb");
  fwrite (rom, 1, 0x40000, fp);
  fclose (fp);

}
