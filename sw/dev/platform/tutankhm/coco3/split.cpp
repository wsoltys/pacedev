#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

unsigned char rom[64*1024];

void usage (char *argv0)
{
  char *p = strrchr (argv0, '\\');

  if (!p) p = argv0;

  printf ("usage: %s [-w] <infile>\n", p);
  printf ("  options:\n");
  printf ("    -w    write output files\n");

  exit (0);
}

int main (int argc, char *argv[])
{
  char *infile = NULL;
  bool bWrite = false;

  if (argc < 2)
    usage (argv[0]);

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' :
      case '/' :
        switch (tolower(argv[argc][1]))
        {
          case 'w' :
            bWrite = true;
            break;
          default :
            usage (argv[0]);
            break;
        }
        break;
      default :
        infile = argv[argc];
    }
  }

  if (!infile)
    usage (argv[0]);

  FILE *fp = fopen (infile, "rb");
  if (!fp) exit (0);

  unsigned char preamble[6] = "\x00\x00\x00\x00\x00";
  unsigned char postamble[6] = "\xFF\x00\x00\x00\x00";
  char buf[32];

  while (!feof (fp))
  {
    fread (preamble, 1, 5, fp);
    if (feof (fp))
      break;

    if (preamble[0] == '\x00')
    {
      unsigned int len = preamble[1];
      len = (len << 8) | preamble[2];
      unsigned int addr = preamble[3];
      addr = (addr << 8) | preamble[4];

      printf ("ADDR = $%04X, LEN = $%04X\n", addr, len);

      if (bWrite)
      {
        // write the output file
        sprintf (buf, "ROM%04X.bin", addr);
        FILE *fp2 = fopen (buf, "wb");
        while (len > 0)
        {
          // write pre-amble to load bank register
          preamble[1] = 0;
          preamble[2] = 1;
          preamble[3] = 0xFF;
          preamble[4] = 0xA2;             // bank for $4000
          fwrite (preamble, 1, 5, fp2);
          unsigned char bank = 16 + (addr >> 13);
          unsigned int offset = addr & 0x1FFF;
          fwrite (&bank, 1, 1, fp2);
        
          // write data block
          unsigned int block_len = (len < (8192-offset) ? len : 8192-offset);
          unsigned int base = 0x4000 + offset;
          fread (rom, 1, block_len, fp);
          preamble[1] = block_len >> 8;
          preamble[2] = block_len & 0xFF;
          preamble[3] = base >> 8;
          preamble[4] = base & 0xFF;              // load at $4000
          fwrite (preamble, 1, 5, fp2);
          fwrite (rom, 1, block_len, fp2);
  
          len -= block_len;
          addr += block_len;
        }

        // write pre-amble to restore bank register
        preamble[1] = 0;
        preamble[2] = 1;
        preamble[3] = 0xFF;
        preamble[4] = 0xA2;             // bank for $4000
        fwrite (preamble, 1, 5, fp2);
        unsigned char bank = 0x3A;
        fwrite (&bank, 1, 1, fp2);
        
        fwrite (postamble, 1, 5, fp2);
        fclose (fp2);
      }
      else
      {
        fread (rom, 1, len, fp);
        if (addr == 0xFFA2)
          printf ("  Bank = $%02X (%d)\n", rom[0], rom[0]);
      }
    }
    else
    if (preamble[0] == 255)
    {
      unsigned int exec = preamble[3];
      exec = (exec << 8) | preamble[4];
      printf ("EXEC = $%04X\n", exec);
    }
    else
    {
      printf ("Unknown header ($%02X) - aborting\n", preamble[0]);
      break;
    }
  }

  fclose (fp);
}
