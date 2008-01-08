#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <memory.h>

void usage (char *exename)
{
  char *p;

  if ((p = strrchr (exename, '\\')) != NULL)
    exename = p;

  printf ("usage: %s <infile>\n", exename);

  exit (0);
}

typedef unsigned char byte;

struct INES_HDR 
{
  char      szNES[4];
  byte      prg;
  byte      chr;
  byte      mapper0_15;
  byte      mapper16_;
  byte      _reserved[8];

} __attribute__((aligned(8),packed));

void dump_ines_hdr (INES_HDR& hdr)
{
  int prg_size = (int)hdr.prg * 16 * 1024;
  int chr_size = (int)hdr.chr * 8 * 1024;

  printf ("\"%-3.3s\" $%02X\n", hdr.szNES, hdr.szNES[3]);
  printf ("PRG = %d x 16KB = %d\n", hdr.prg, prg_size);
  printf ("CHR = %d x  8KB = %d\n", hdr.chr, chr_size);
  printf ("$%02X\n", hdr.mapper0_15);
  printf ("$%02X\n", hdr.mapper16_);
}

int main (int argc, char *argv[])
{
  if (--argc != 1)
    usage (argv[0]);

  struct stat fs;
  if (stat (argv[1], &fs) != 0)
  {
    printf ("error: stat() failed!\n");
    exit (0);
  }

  printf ("stat.st_size = %d\n", fs.st_size);

  FILE *fp = fopen (argv[1], "rb");
  if (!fp)
  {
    printf ("error: fopen() failed!\n");
    exit (0);
  }

  INES_HDR hdr;
  fread (&hdr, sizeof(INES_HDR), 1, fp);
  dump_ines_hdr (hdr);

  char name[128], *p;
  strcpy (name, argv[1]);
  if ((p = strrchr(name, '.')) == NULL)
    p = name + strlen(name);

  // dump PRG rom
  strcpy (p, ".PRG");
  int size = (int)hdr.prg * 16 * 1024;
  byte *buf = (byte *)malloc (size);
  fread (buf, 1, size, fp);
  FILE *fpprg = fopen (name, "wb");
  fwrite (buf, 1, size, fpprg);
  fclose (fpprg);
  free (buf);

  // dump CHR rom
  strcpy (p, ".CHR");
  size = (int)hdr.chr * 8 * 1024;
  buf = (byte *)malloc (size);
  fread (buf, 1, size, fp);
  FILE *fpchr = fopen (name, "wb");
  fwrite (buf, 1, size, fpchr);
  fclose (fpchr);
  free (buf);

  fclose (fp);
}
