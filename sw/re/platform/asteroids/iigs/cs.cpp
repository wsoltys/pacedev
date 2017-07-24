#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>

unsigned int ahextoi (char *buf)
{
  unsigned v;
  
  for (v=0; *buf; buf++)
  {
    if (isdigit(*buf))
      v = (v<<4) | *buf - '0';
    else
    if (isalpha(*buf))
      v = (v<<4) | toupper(*buf) - 'A' + 10;
    else
      break;
  }
  
  return (v);
}

int main (int argc, char *argv[])
{
	FILE *fp = fopen ("bitmaps.asm", "rt");
	if (!fp)
		exit (0);

  FILE *fpR = fopen ("cs_r.asm", "wt");
  if (!fpR)
    exit (0);
    
  FILE *fpE = fopen ("cs_e.asm", "wt");
  if (!fpE)
    exit (0);
    	
	char buf[1024];
		
	fgets (buf, 1024, fp);
	while (!feof (fp))
	{
		//printf ("%s", buf);

    if (isalpha (buf[0]) && strchr (buf, ':'))
		{
		  char name[1024];

		  strcpy (name, buf);
		  fgets (buf, 1024, fp);

		  fprintf (fpR, "%s", name);
		  fprintf (fpE, "%s", name);

      uint16_t addr = 0;
		  while (1)
		  {
    		fprintf (fpR, ";%s", buf+1);
    		fprintf (fpE, ";%s", buf+1);

		    if (!strstr (buf, ".BYTE") && !strstr (buf, ".byte"))
		      break;

        char *p;
        uint16_t offset = 0;
        for (p=buf; (p = strchr (p, '$')); offset+=2)
        {
          uint16_t data;
          
          p++;
          data = ahextoi (p);
          p = strchr (p, '$');
          if (!p) break;
          p++;
          data |= (ahextoi (p) << 8);

          if (data == 0)
            continue;

          fprintf (fpR, "        lda     #$%04X\n", data);
          fprintf (fpR, "        ora     SHRMEM+$%03X,x\n", addr+offset);
          fprintf (fpR, "        sta     SHRMEM+$%03X,x\n", addr+offset);
          
          fprintf (fpE, "        sta     SHRMEM+$%03X,x\n", addr+offset);
        }
		    
		    addr += 160;  
		    fgets (buf, 1024, fp);
		  }
    }

		fgets (buf, 1024, fp);
	}
	
	fclose (fp);
	fclose (fpR);
	fclose (fpE);
}
