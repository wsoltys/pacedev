#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int ahtoi (char *buf)
{
  int v = 0;

  for (; isalnum(*buf); buf++)
  {
    v <<= 4;
    if (isdigit (*buf))
      v += *buf - '0';
    else
      v += toupper (*buf) - 'A' + 10;
  }

  return (v);
}

int main (int argc, char *argv[])
{
  FILE *fp = fopen ("iplrom.vhd", "rt");
  if (!fp) exit (0);

  FILE *fp2 = fopen ("iplrom.bin", "wb");
  if (!fp2) exit (0);

  int bFoundData = 0;

  while (!feof (fp))
  {
    char buf[256];

    fgets (buf, 255, fp);

    if (strstr (buf, "ipl_data"))
    {
      bFoundData = 1;
      continue;
    }
    if (!bFoundData)
      continue;
    if (strstr (buf, ");"))
      break;

    // found a data line - parse it
    char *p;
    for (p=buf; p;)
    {
      if ((p = strstr (p, "X\"")))
      {
        p += 2;
        unsigned char b = (unsigned char)ahtoi (p);
        //printf ("$%02X ", b);
        fwrite (&b, 1,1, fp2);
      }
    }
    //printf ("\n");

    //printf (buf);
  }

  fclose (fp2);
  fclose (fp);
}
