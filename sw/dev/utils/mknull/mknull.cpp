#include <stdio.h>
#include <stdlib.h>

void usage (char *argv0)
{
  printf ("usage: %s <kb>\n", argv0);
  exit (0);
}

int main (int argc, char *argv[])
{
  if (--argc != 1)
    usage (argv[0]);
  int kb = atoi(argv[1]);

  char filename[64];
  sprintf (filename, "null%dk.bin", kb);

  FILE *fp = fopen (filename, "wb");
  char null = '\0';
  int i;
  for (i=0; i<kb*1024; i++)
    fwrite (&null, 1, 1, fp);
  fclose (fp);
}
