#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char *ahextol (char *buf, unsigned long int &val)
{
  val = 0;
  
  for (; *buf; buf++)
  {
    if (!isdigit(*buf) && (*buf < 'A' || *buf > 'F'))
      break;
    val <<= 4;
    if (isdigit(*buf))
      val += *buf - '0';
    else
      val += *buf - 'A' + 10;
  }
  
  return (buf);
}

int main (int argc, char *argv[])
{
  FILE *fpEnt = fopen ("trk80.ent", "rb");
  FILE *fpBin = fopen ("trk80.bin", "wb");
  char buf[128];
  unsigned a = 0;
  
  while (1)
  {
    char *p;

    fgets (buf, 128, fpEnt);
    if (feof (fpEnt))
      break;
      
    if (!strchr (buf, ':'))
      continue;

    //printf ("%s", buf);      
    unsigned long int la;
    
    p = ahextol (buf, la);
    printf ("$%04X: ", la);
    if (la != a)
      printf ("\nwarning A=$%04X != LA=$%04X!\n", a, la);

    p++;
    while (*p)
    {
      unsigned long int li;
      unsigned char byte;
      
      while (isspace(*p)) p++;
      if (*p == 0) break;
      if (*p == '/') break;
          
      p = ahextol (p, li);
      byte = (unsigned char)li;
      printf ("%02X ", byte);
      
      fwrite (&byte, sizeof(unsigned char), 1, fpBin);
    }
    printf ("\n");
    a += 16;
  }  

  printf ("\n"); fflush (stdout);
  
  fclose (fpBin);
  fclose (fpEnt);
}
