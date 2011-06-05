#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned char rom[16*1024];

int find_str(char *str, int rom_len)
{
  int j;
  
  for (int i=0; i<rom_len-strlen(str); i++)
  {
    for (j=1; j<strlen(str); j++)
      if ((rom[i+j]-rom[i]) != (str[j]-str[i]))
        break;
    if (j == strlen(str))
      printf ("Candidate @offset=$%X\n", i);
  }
  
  return (0);
}

int main (int argc, char *argv[])
{
  // MAIN

  printf ("main.bin\n");
    
  FILE *fp = fopen ("main.bin", "rb");
  fread (rom, 16*1024, 1, fp);
  fclose (fp);

  for (int i=0; i<16*1024; i++)
  {
  	//rom[i] ^= 0xFF;
  	
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
	}
	      
  fp = fopen ("main.asc", "wb");
  fwrite (rom, 16*1024, 1, fp);
  fclose (fp);

  // SUB

  printf ("sub.bin\n");
  
  fp = fopen ("sub.bin", "rb");
  fread (rom, 8*1024, 1, fp);
  fclose (fp);

  find_str ("WARRIORS", 8*124);

  for (int i=0; i<8*1024; i++)
    if (rom[i] < 10)
      rom[i] += '0';
    else
      rom[i] += 'A' - 10;
      
  fp = fopen ("sub.asc", "wb");
  fwrite (rom, 8*1024, 1, fp);
  fclose (fp);

  // SUB2
  
  printf ("sub2.bin\n");
  
  fp = fopen ("sub2.bin", "rb");
  fread (rom, 4*1024, 1, fp);
  fclose (fp);

  find_str ("WARRIORS", 4*124);

  for (int i=0; i<4*1024; i++)
    if (rom[i] < 10)
      rom[i] += '0';
    else
      rom[i] += 'A' - 10;
      
  fp = fopen ("sub2.asc", "wb");
  fwrite (rom, 4*1024, 1, fp);
  fclose (fp);

}
