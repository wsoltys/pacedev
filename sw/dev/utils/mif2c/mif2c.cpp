/*

    -- MIF file representing initial state of PLL Scan Chain
    --    Device Family: Cyclone III
    --    Device Part: -
    --    Device Speed Grade: 6
    --    PLL Scan Chain: Fast PLL (144 bits)
    --    File Name: D:\markm\pace\bork.us.to\pace-vcb\sw\MCE-sw-VCB\synth\mega\dvo_pll.mif
    --    Generated: Fri Oct 16 13:06:30 2009
    
    WIDTH=1;
    DEPTH=144;
    
    ADDRESS_RADIX=UNS;
    DATA_RADIX=UNS;
    
    CONTENT BEGIN
    	0    :   0; -- Reserved Bits = 0 (1 bit(s))
    	1    :   0; -- Reserved Bits = 0 (1 bit(s))
    	2    :   0; -- Loop Filter Capacitance = 0 (2 bit(s)) (Setting 0)
    	3    :   0;
    	4    :   1; -- Loop Filter Resistance = 16 (5 bit(s)) (Setting 16)
    	5    :   0;
    ..
    	11   :   0;
    	12   :   0;
    	13   :   0;
    	142  :   0;
    	143  :   0;
    END;

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define DATA_WIDTH    9

int main (int argc, char *argv[])
{
  FILE *fp = fopen (argv[1], "rt");
  if (!fp)
  {
    fprintf (stderr, "Unable to open inpout file \"%s\"!\n", argv[1]);
    exit (0);
  }

  int width = 0;
  int depth = 0;
  char address_radix[32] = "";
  char data_radix[32] = "";
  bool content_begin = false;
  unsigned long int a;

  unsigned int data9 = 0;

  printf ("alt_u16 mif_data[] = \n");
  printf ("{\n");
    
  while (!feof (fp))
  {
    char buf[1024];
    char *p;
    
    fgets (buf, 1023, fp);
    p = buf;
    
    // skip leading spaces
    while (isspace(*p)) p++;
    // check for null line or comment
    if (*p == 0 || !strncmp (p, (char *)"--", 2))
      continue;

    if (!strncmp (p, (char *)"END;", 4))
      break;
  
    if (!strncmp (p, (char *)"WIDTH=", 6))
    {
      p = strchr (p, '=') + 1;
      width = atoi(p);
      continue;
    }
      
    if (!strncmp (p, (char *)"DEPTH=", 6))
    {
      p = strchr (p, '=') + 1;
      depth = atoi(p);
      continue;
    }

    if (!strncmp (p, (char *)"ADDRESS_RADIX=", 14))
    {
      p = strchr (p, '=') + 1;
      char *q = address_radix;
      while (!isspace(*p)) *(q++) = *(p++);
      *q = '\0';
      continue;
    }

    if (!strncmp (p, (char *)"DATA_RADIX=", 11))
    {
      p = strchr (p, '=') + 1;
      char *q = data_radix;
      while (!isspace(*p)) *(q++) = *(p++);
      *q = '\0';
      continue;
    }

    if (!strncmp (p, (char *)"CONTENT BEGIN", 13))
    {
      content_begin = true;
      continue;
    }

    if (!content_begin)
      continue;

    unsigned long int data;   // for worst case
    
    // for now, going to assume contiguous, padded data
    // - fixme if/when required
    
    while (isspace(*p)) p++;
    a = atoi(p);
    p = strchr (buf, ':');
    if (!p++) continue;
    while (isspace(*p)) p++;
    
    // now pull some data out
    data = atoi(p);
    data9 = (data9 << width) | (data & ((1<<width)+1));
    if ((a%DATA_WIDTH) != DATA_WIDTH-1)
      continue;

    // do some printing
    a /= DATA_WIDTH;
    if ((a%8) == 0) printf ("  ");
    printf ("0x%03X, ", data9);
    data9 = 0;
    if ((a%8) == 7) printf ("\n");
  }
  if ((a%8) != 7) printf ("\n");
  printf ("};\n");
    
  fclose (fp);
  
  fprintf (stderr, "width=%d\n", width);
  fprintf (stderr, "depth=%d\n", depth);
  fprintf (stderr, "address_radix=%s\n", address_radix);
  fprintf (stderr, "data_radix=%s\n", data_radix);
  
}
