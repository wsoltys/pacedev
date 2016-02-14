#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>

uint8_t ram_zx[0x10000];
uint8_t ram_cpc[0x10000];

int main (int argc, char *argv[])
{
	struct stat	    fs;
	int					    fd;

  FILE *fpZx = fopen ("../knightlore.bin", "rb");
	if (!fpZx)
		exit (0);
	fd = fileno (fpZx);
	if (fstat	(fd, &fs))
		exit (0);
  fread (&ram_zx[0x6108], sizeof(uint8_t), fs.st_size, fpZx);
  fclose (fpZx);

  FILE *fpCpc = fopen ("../../../cpc/kl_cpc.bin", "rb");
	if (!fpCpc)
		exit (0);
	fd = fileno (fpCpc);
	if (fstat	(fd, &fs))
		exit (0);
  fread (&ram_cpc[0x0000], sizeof(uint8_t), fs.st_size, fpCpc);
  fclose (fpCpc);

  unsigned a_zx = 0x6251;
  unsigned a_cpc = 0x33dd;
  
  //compare location tables
  while (a_zx < 0x6bd1)
  {
    if (ram_zx[a_zx] != ram_cpc[a_cpc])
    {      
      printf ("@$%04X[$%02X] != @$%04X[$%02X]\n",
              a_zx, ram_zx[a_zx], a_cpc, ram_cpc[a_cpc]);
    }
                
    a_zx++;
    a_cpc++;
  }

  // compare background object tables
    
  fprintf (stderr, "Done!\n");
}
