#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>
#include <string.h>

static unsigned char rom[64*1024];

int find_str(char *str, int rom_len)
{
  int j;
  
  for (int i=0; i<rom_len-strlen(str); i++)
  {
    for (j=1; j<strlen(str); j++)
      if ((rom[i+j]-rom[i]) != (str[j]-str[0]))
        break;
    if (j == strlen(str))
      printf ("Candidate @offset=$%X\n", i);
  }
  
  return (0);
}

int main (int argc, char *argv[])
{
  printf ("lr_disk.bin\n");
  
	struct stat	fs;
	int					fd;
    
  FILE *fp = fopen ("lr_disk.bin", "rb");
  if (!fp)
  	exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
  
  fread (rom, 1, fs.st_size, fp);
  fclose (fp);

	find_str ("SCORE", fs.st_size);
	
  for (int i=0; i<fs.st_size; i++)
  {
  	//rom[i] ^= 0xFF;

#if 0  	
    if (rom[i] < 10)
      rom[i] += '0';
    else if (rom[i] < 0x24)
      rom[i] += -10 + 'A';
    else if (rom[i] == 0x24)
    	rom[i] = ' ';
   	else if (rom[i] < 0x50)
   		rom[i] += -0x36 + 'a';
   	else
   		rom[i] = '.';
#else
	rom[i] -= 0x80;
#endif   		
	}
	      
  fp = fopen ("lr_disk.asc", "wb");
  fwrite (rom, 1, fs.st_size, fp);
  fclose (fp);
}
