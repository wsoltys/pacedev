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
  {
    fprintf (stderr, "unable to open %s for reading!\n", infile);
	  usage (argv[0]);
	}

	fp2 = fopen (outfile, "wb");

	struct stat	fs;
	int					fd;

	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);

  uint32_t remaining = fs.st_size;
  uint8_t bank = ((remaining > 16*1024) ? 0x30 : 0x32);
  uint16_t addr = ((remaining > 16*1024) ? 0x8000 : 0xC000);
      
  while (remaining)
  {
    uint16_t len = (uint16_t)remaining;
    if (len > 0x2000)
      len = 0x2000;

    // write pre-amble to load bank register
    amble[0] = 0;
    amble[1] = 0;
    amble[2] = 1;
    amble[3] = 0xFF;
    amble[4] = 0xA2;             			  // MMU bank register for $4000
    fwrite (amble, sizeof(uint8_t), 5, fp2);
    fwrite (&bank, sizeof(uint8_t), 1, fp2);

    if (verbose)
      fprintf (stderr, "$FFA2=$%02X\n", bank);

    // write pre-amble for data page      
    amble[0] = 0;
    amble[1] = len >> 8;
    amble[2] = len & 0xff;
    amble[3] = 0x40;
    amble[4] = 0x00;
    fwrite (amble, sizeof(uint8_t), 5, fp2);
    
    fread (buf, sizeof(uint8_t), len, fp);
    fwrite (buf, sizeof(uint8_t), len, fp2);

    if (verbose)
      fprintf (stderr, "Writing data @$%04X len=$%04X\n", 
                addr, len);

    remaining -= len;
    bank++;
    addr += len;    
  }

  // restore bank register
  amble[0] = 0;
  amble[1] = 0;
  amble[2] = 1;
  amble[3] = 0xFF;
  amble[4] = 0xA2;             			  // MMU bank register for $4000
  fwrite (amble, sizeof(uint8_t), 5, fp2);
  bank = 0x3A;
  fwrite (&bank, sizeof(uint8_t), 1, fp2);

  if (verbose)
    fprintf (stderr, "$FFA2=$%02X\n", bank);


  // postamble - never executed
  amble[0] = 0xff;
  amble[1] = 0;
  amble[2] = 0;
  amble[3] = 0;
  amble[4] = 0;
  fwrite (amble, sizeof(uint8_t), 5, fp2);
  
	fclose (fp);
	fclose (fp2);
}
