#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

/*
 *  IDA: Options->Target Assembler->Public Domain 6809 assembler v2.01 (OS9 support)
 *    Fixes:
 *      - labels on empty lines (adds "equ *")
 *      - fcb doesn't like white spaces between ","
 *    Also requires:
 *      - IDA.CFG: XlatAsciiName - translate '@','?' to eg, '_'
 *
 *    CCASM:
 *      cm <infile>.asm -v -l -s -nr -o=<infile>.bin ><infile>.lst
 */

void usage (char *argv0)
{
  char *p = strrchr (argv0, '\\');
  if (!p) p = argv0;

  printf ("usage: %s <infile>[.asm]\n", p);
  exit (0);
}

int main (int argc, char *argv[])
{
  if (--argc != 1)
    usage (argv[0]);

  char buf[132];
  sprintf (buf, argv[1]);
  if (!strchr (buf, '.'))
    strcat (buf, ".asm");
  FILE *fp = fopen (buf, "rt");
  if (!fp) exit (0);

  int n = 0;

  while (!feof (fp))
  {
    char *p;

    fgets (buf, 131, fp);

    // handle fcb
    if ((p = strstr (buf, "\tfcb ")) ||
        (p = strstr (buf, " fcb ")))
    {
      while (p = strchr (p, ','))
      {
        while (isspace (*(p+1)))
          strcpy (p+1, p+2);
        p++;
      }
      printf (buf);
      n++;
      continue;
    }

    #if 1
    // handle lines with no label
    if (!isalpha (*buf))
    {
      printf (buf);
      continue;
    }

    // skip label
    p = buf;
    while (!isspace (*p))
      p++;
    // skip white spaces
    while (isspace (*p))
      p++;

    if (isalpha (*p))
      printf (buf);
    else
    {
      if (*p)
        printf ("%.*s", p-buf, buf);
      else
        printf ("%.*s", p-buf-1, buf);
      printf ("\tequ\t*\t%s", p);
      printf ("\n");
      n++;
    }
    #else
      printf (buf);
    #endif
  }

  fclose (fp);
  fprintf (stderr, "%d lines converted\n", n);
}
