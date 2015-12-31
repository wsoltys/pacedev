#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <sys/stat.h>
#include <memory.h>

#pragma pack(1)
typedef struct
{
  uint8_t   i;
  uint16_t  hl_, de_, bc_, af_;
  uint16_t  hl, de, bc, iy, ix;
  uint8_t   interrupt;
  uint8_t   r;
  uint16_t  af, sp;
  uint8_t   intmode;
  uint8_t   bordercolor;
      
} SNAHDR, *PSNAHDR;

//#define SWAP(d) (((d<<8)&0xFF00)|((d>>8)&0x00FF))
#define SWAP(d) (d)

uint8_t ram[64*1024];

void dump_sna_hdr (PSNAHDR hdr)
{
  fprintf (stderr, "%16.16s = 0x%02X\n", "I", hdr->i);
  fprintf (stderr, "%16.16s = 0x%04X\n", "HL'", SWAP(hdr->hl_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "DE'", SWAP(hdr->de_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "BC'", SWAP(hdr->bc_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "AF'", SWAP(hdr->af_));
  fprintf (stderr, "%16.16s = 0x%04X\n", "HL", SWAP(hdr->hl));
  fprintf (stderr, "%16.16s = 0x%04X\n", "DE", SWAP(hdr->de));
  fprintf (stderr, "%16.16s = 0x%04X\n", "BC", SWAP(hdr->bc));
  fprintf (stderr, "%16.16s = 0x%04X\n", "IY", SWAP(hdr->iy));
  fprintf (stderr, "%16.16s = 0x%04X\n", "IX", SWAP(hdr->ix));
  fprintf (stderr, "%16.16s = 0x%02X\n", "Interrupt", hdr->interrupt);
  fprintf (stderr, "%16.16s = 0x%02X\n", "R", hdr->r);
  fprintf (stderr, "%16.16s = 0x%04X\n", "AF", SWAP(hdr->af));
  fprintf (stderr, "%16.16s = 0x%04X\n", "SP", SWAP(hdr->sp));
  fprintf (stderr, "%16.16s = 0x%02X\n", "IntMode", hdr->intmode);
  fprintf (stderr, "%16.16s = 0x%02X\n", "BorderColor", hdr->bordercolor);

  uint16_t  sp = SWAP(hdr->sp);
  uint16_t  ret = ram[sp+1];
  ret = (ret<<8)|ram[sp+0];
  fprintf (stderr, "%16.16s = 0x%04X\n", "RET", ret);
}

uint16_t ahtoi (char *str)
{
  uint16_t val = 0;
  
  for (; *str; str++)
  {
    if (isdigit (*str))
      val = (val << 4) + *str - '0';
    else if (isalpha (*str) && tolower(*str) >= 'a' && tolower(*str) <= 'f')
      val = (val << 4) + *str - 'a' + 10;
    else break;  
  }
  return (val);
}

void usage (char *argv0)
{
  printf ("usage:\n");
  printf ("  %s -a<nnnn> -i<nn> -m<nn> -n<nn> -s<nnnn> -x<nnnn> binfile [snafile]\n",
            argv0);
  printf ("    -a     load address=$nnnn [$4000]\n");
  printf ("    -i     I=$nn [$00]\n");
  printf ("    -m     IntMode=$nn [$00]\n");
  printf ("    -n     Interrupt=$nn [$00]\n");
  printf ("    -s     SP=$nnnn\n");
  printf ("    -x     RET=$nnnn [$4000]\n");
}

int main (int argc, char *argv[])
{
	FILE          *fp;
	struct stat	  fs;
	int           fd;
	SNAHDR        snahdr;
	char          sz_bin[64], sz_sna[64];
	uint16_t      addr = 0x4000;
  uint16_t      ret = 0x4000;
  
  sz_bin[0] = '\0';
  sz_sna[0] = '\0';
  memset (&snahdr, 0, sizeof(SNAHDR));
  
	for (unsigned a=1; a<argc; a++)
	{
	  switch (argv[a][0])
	  {
	    case '-' :
      case '/' :
        switch (tolower(argv[a][1]))
        {
          case 'a' :
            addr = ahtoi(&argv[a][2]);
            break;
          case 'i' :
            snahdr.i = ahtoi(&argv[a][2]);
            break;
          case 'n' :
            snahdr.interrupt = ahtoi(&argv[a][2]);
            break;
          case 'm' :
            snahdr.intmode = ahtoi(&argv[a][2]);
            break;
          case 's' :
            snahdr.sp = ahtoi(&argv[a][2]);
            break;
          case 'x' :
            ret = ahtoi(&argv[a][2]);
            break;
          case 'h' :
          case '?' :
          default :
            usage (argv[0]);
            break;
        }
        break;
      default :
        if (*sz_bin == '\0')
          strcpy (sz_bin, argv[a]);
        else if (*sz_sna == '\0')
          strcpy (sz_sna, argv[a]);
        break;
	  }
	}

  if (*sz_bin == '\0')
    usage (argv[0]);
  if (*sz_sna == '\0')	
  {
    char *p;
    strcpy (sz_sna, sz_bin);
    if ((p = strrchr (sz_sna, '.')) == NULL)
      strcat (sz_sna, ".sna");
    else
      strcpy (p+1, "sna");
  }
  //if (strrchr (sz_bin, '.') == NULL)
  //  strcat (sz_bin, ".bin");
    
  fp = fopen (sz_bin, "rb");
  if (!fp)
  {
    fprintf (stderr, "Unable to open BIN file \"%s\"!\n", sz_bin);
    exit (0);
  }
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (&ram[addr], sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);

  // insert return address on stack
  ram[snahdr.sp+0] = ret & 0xFF;	
  ram[snahdr.sp+1] = ret >> 8;
  
  dump_sna_hdr (&snahdr);
  
  fp = fopen (sz_sna, "wb");
  if (!fp)
  {
    fprintf (stderr, "Unable to open SNA file \"%s\"!\n", sz_sna);
    exit (0);
  }
  fwrite (&snahdr, 1, sizeof(SNAHDR), fp);
  fwrite (&ram[0x4000], 1, 49152, fp);
  fclose (fp);
}
