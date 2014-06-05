#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

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

  uint16_t  last_addr = 0;
  uint16_t  org = 0;
  uint16_t  rel = 0;
  
  int16_t   offset = 0x4000-0x8000;

  // write pre-amble to load bank register
  amble[1] = 0;
  amble[2] = 2;
  amble[3] = 0xFF;
  amble[4] = 0xA2;             			  // MMU bank register for $4000
  fwrite (amble, sizeof(uint8_t), 5, fp2);
  uint8_t bank[2] = { 0x00, 0x01 };		// 60/1, or $8000 in memory
  fwrite (bank, sizeof(uint8_t), 2, fp2);
  
  while (1)
  {
    fread (amble, sizeof(uint8_t), 5, fp);
    if (feof (fp))
      break;
          
    if (amble[0] == 0x00)
    {
      uint16_t len = ((uint16_t)amble[1] << 8) | amble[2];
      uint16_t addr = ((uint16_t)amble[3] << 8) | amble[4];

      if (verbose)      
        fprintf (stderr, "PRE: len=0x%04X, addr=0x%04X\n", len, addr);
      //fseek (fp, len, SEEK_CUR);

      if (addr != last_addr)
       if (verbose)
         fprintf (stderr, "non-contiguous (0x%04X-0x%04X)\n",
                  last_addr, addr);
      last_addr = addr + len;

      fread (buf, sizeof(uint8_t), len, fp);

      if (org == 0)
        org = addr;
        
      // relocate block
      addr += offset;
      //fprintf (stderr, "addr=0x%04X\n", addr);
      amble[3] = addr >> 8;
      amble[4] = addr & 0xff;
      fwrite (amble, sizeof(uint8_t), 5, fp2);

      fwrite (buf, sizeof(uint8_t), len, fp2);

      if (rel == 0)
        rel = addr;
        
      continue;
    }
    
    if (amble[0] == 0xFF)
    {
      uint8_t   postamble[5];
      
      memcpy (postamble, amble, 5);
      
      uint16_t exec = ((uint16_t)postamble[3] << 8) | postamble[4];

      if (verbose)
        fprintf (stderr, "POST: exec=0x%04X\n", exec);

      // write pre-amble to restore bank register
      amble[0] = 0;         // preamble
      amble[1] = 0;
      amble[2] = 2;
      amble[3] = 0xFF;
      amble[4] = 0xA2;      // MMU bank register for $4000
      fwrite (amble, sizeof(uint8_t), 5, fp2);
      bank[0] = 0x3A;				// 58, or $4000 in memory
      bank[1] = 0x3B;
      fwrite (bank, 1, 2, fp2);

      static uint8_t ldr[] =
      {
        0x86, 0x00,         // LDA #0
        0x8E, 0xFF, 0xA4,   // LDX $FFA4 (MMUTSK1+4 = $8000)
        0xA7, 0x80,         // STA ,X+
        0x4C,               // INCA
        0xA7, 0x80,         // STA ,X+
        0x7E, 0x80, 0x00    // JMP $8000        
      };
      #define LDR_SIZE (sizeof(ldr)/sizeof(uint8_t))
      
      // inject loader
      amble[0] = 0;
      amble[1] = 0;
      amble[2] = LDR_SIZE;
      amble[3] = 0x40;
      amble[4] = 0x00;
      fwrite (amble, sizeof(uint8_t), 5, fp2);
      fwrite (ldr, sizeof(uint8_t), LDR_SIZE, fp2);
      
      // write postamble
      exec += offset;
      postamble[3] = 0x40;
      postamble[4] = 0x00;
      fwrite (postamble, sizeof(uint8_t), 5, fp2);

      continue;
    }
    
    fprintf (stderr, "error: unexpected format!\n");
    break;
  }	

	fclose (fp);
	fclose (fp2);
	
	fprintf (stderr, "Relocated \"%s\" ($%04X) -> \"%s\" ($%04X)\n", 
	          infile, org, outfile, rel);
}
