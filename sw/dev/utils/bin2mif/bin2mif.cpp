#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

int main (int argc, char *argv[])
{
  if (--argc != 1)
    exit (0);

  char bin_file[128], *p;
  strcpy (bin_file, argv[argc]);
  if (strrchr (bin_file, '.') == NULL)
    strcat (bin_file, ".bin");

  FILE *fp_bin = fopen (bin_file, "rb");
  if (!fp_bin)
    exit (0);

  char mif_file[128];
  strcpy (mif_file, bin_file);
  if (p = strrchr (mif_file, '.'))
    *p = '\0';
  strcat (mif_file, ".mif");

  // get the size of the bin file
  struct stat sbuf;
  if (stat (bin_file, &sbuf))
    exit (0);

  //printf ("WIDTH=8;\n");
  printf ("WIDTH=16;\n");
  sbuf.st_size /= 2;
  printf ("DEPTH=%d;\n", sbuf.st_size);
  printf ("ADDRESS_RADIX=UNS;\n");
  printf ("DATA_RADIX=HEX;\n");
  printf ("CONTENT BEGIN\n");

  for (int i=0; i<sbuf.st_size; i++)
  {
    unsigned short int word;
    unsigned char byte;
    fread (&byte, sizeof(unsigned char), 1, fp_bin);
    word = byte;
    fread (&byte, sizeof(unsigned char), 1, fp_bin);
    word = (word << 8) | byte;
    printf ("    %-6d : %04X;\n", i, word);
  }

  printf ("END;\n");

  fclose (fp_bin);
}
