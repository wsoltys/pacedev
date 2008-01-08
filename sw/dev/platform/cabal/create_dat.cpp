#include <stdio.h>
#include <stdlib.h>

char *chr2bin (unsigned char c)
{
  static char str[32];
  int i;

  for (i=0; i<8; i++)
    str[i] = (c & (1<<(7-i)) ? '1' : '0');
  str[i] = '\0';

  return (str);
}

int main (int argc, char *argv[])
{
  FILE *fpin = fopen ("cabal_rom.bin", "rb");
  if (!fpin)
    exit (0);

  char buf[32];
  int i;

  int address = 0;
  while (!feof (fpin))
  {
    fread (buf, 1, 2, fpin);
    printf ("%d ", address++);
    for (i=0; i<2; i++)
      printf ("%s", chr2bin(buf[i]));
    printf ("  ; %02x%02x\n", buf[0], buf[1]);

    //if (address == 4096) break;
  }

  fclose (fpin);
}
