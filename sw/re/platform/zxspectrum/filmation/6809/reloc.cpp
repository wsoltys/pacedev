#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

#define RELOC_ADDR  0x2000
#define BASE_ADDR   0x8000

//  uint8_t preamble[6] = "\x00\x00\x00\x00\x00";
//  uint8_t postamble[6] = "\xFF\x00\x00\x00\x00";

uint8_t amble[5];
uint8_t buf[64*1024];

void usage (char *argv0)
{
  if (strrchr (argv0, '\\'))
    argv0 = strrchr (argv0, '\\');
    
  fprintf (stderr, "usage:\n");
  fprintf (stderr, "  %s [-v] infile[.bin] outfile[.bin]\n", argv0);
  fprintf (stderr, "    -v          verbose\n");
  fprintf (stderr, "    infile      input file\n");
  fprintf (stderr, "    outfile     output file\n");
  
  exit (0);
}

int main (int argc, char *argv[])
{
	FILE *fp, *fp2;
	char infile[128] = { '\0' };
	char outfile[128] = { '\0' };
  bool verbose = false;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' :
      case '/' :
        switch (tolower (argv[argc][1]))
        {
          case 'v' :
            verbose = 1;
            break;
            
          default :
            usage (argv[0]);
            break;
        }
        break;
        
      default :
        if (*outfile)
          strcpy (infile, argv[argc]);
        else
          strcpy (outfile, argv[argc]);
        break;        
    }
  }

  if (*outfile == '\0' || *infile == '\0')
    usage (argv[0]);
  if (!strchr (infile, '.'))
    strcat (infile, ".bin");
  if (!strchr (outfile, '.'))
    strcat (outfile, ".bin");
    	
	fp = fopen (infile, "rb");
	if (!fp)
	  usage (argv[0]);

	fp2 = fopen (outfile, "wb");

  while (1)
  {
    fread (amble, sizeof(uint8_t), 5, fp);
    if (feof (fp))
      break;

    uint32_t len = 0;
    uint8_t block = amble[0];
    len = (len << 8) | amble[1];
    len = (len << 8) | amble[2];
    uint16_t addr = 0;
    addr = (addr << 8) | amble[3];
    addr = (addr << 8) | amble[4];
    if (verbose)
      fprintf (stderr, "block=$%02X, len=$%06lX, addr=$%04X\n",
                block, len, addr);

    if (block == 0)
    { 
      if (amble[3] != 0xFF || (amble[4] & 0xF0) != 0xA0)
      {
        addr = (addr - BASE_ADDR) + RELOC_ADDR;
        amble[3] = (addr >> 8);
        amble[4] = (addr &0xFF);
      }
    }
    fwrite (amble, sizeof(uint8_t), 5, fp2);

    // write data
    if (block == 0 && len)
    {
      fread (buf, sizeof(uint8_t), len, fp);
      fwrite (buf, sizeof(uint8_t), len, fp2);
    }
  }

	fclose (fp);
	fclose (fp2);
	
	fprintf (stderr, "Relocated \"%s\" ($%04X) -> \"%s\" ($%04X)\n", 
	          infile, BASE_ADDR, outfile, RELOC_ADDR);
}
