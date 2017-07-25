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

		  fprintf (fpR, "%s", name);
		  fprintf (fpE, "%s", name);

      long fpos = ftell (fp);
      
      uint16_t offs_tbl[256];
      int n_offs;
      
      for (unsigned i=1; i<16; i++)
      {
        fseek (fp, fpos, SEEK_SET);
		    fgets (buf, 1024, fp);

        uint16_t value = 0;
        if (i&(1<<3)) value |= 0xF000;
        if (i&(1<<2)) value |= 0x0F00;
        if (i&(1<<1)) value |= 0x00F0;
        if (i&(1<<0)) value |= 0x000F;

        uint16_t addr = 0;
        n_offs = 0;
  		  while (1)
  		  {
  		    if (!strstr (buf, ".BYTE") && !strstr (buf, ".byte"))
  		      break;

      		//fprintf (fpR, ";%s", buf+1);
      		//fprintf (fpE, ";%s", buf+1);
  
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
  
            if (data != value)
              continue;
  
            offs_tbl[n_offs++] = addr+offset;
          }
  		    
  		    addr += 160;  
  		    fgets (buf, 1024, fp);
  		  }

		    // now output
		    if (n_offs > 3)
          fprintf (fpR, "        ldy     #$%04X\n", value);
        for (unsigned i=0; i<n_offs; i++)
        {  
          if (n_offs > 3)
            fprintf (fpR, "        tya\n");
          else
            fprintf (fpR, "        lda     #$%04X\n", value);
          if (value != 0xFFFF)
            fprintf (fpR, "        ora     SHRMEM+$%03X,x\n", offs_tbl[i]);
            fprintf (fpR, "        sta     SHRMEM+$%03X,x\n", offs_tbl[i]);
            
            fprintf (fpE, "        sta     SHRMEM+$%03X,x\n", offs_tbl[i]);
		    }

  		} // value
    } // isalpha

		fgets (buf, 1024, fp);
	}
	
	fclose (fp);
	fclose (fpR);
	fclose (fpE);
}
