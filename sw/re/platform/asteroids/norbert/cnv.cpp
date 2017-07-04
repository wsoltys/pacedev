#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int char_pics (void)
{
	FILE *fp = fopen ("char_pics.asm", "rt");
	if (!fp)
		exit (0);
	
	char buf[1024];
		
	fgets (buf, 1024, fp);
	while (!feof (fp))
	{
		//printf ("%s", buf);
		
		if (strncmp (buf, "char_pic", 8) &&
		   (!strncmp (buf, "char_", 5) ||
		    !strncmp (buf, "ship_", 5)))
		{
			char *p = buf;
			while (!isspace (*p))
				p++;
			sprintf (p, ":");
			printf ("%s\n", buf);
			unsigned long dword = 0;
			for (unsigned i=0; i<7; i++)
			{
				fgets (buf, 1024, fp);
				// convert 1bpp to 4bpp
				p = strchr (buf, '%');
				if (!p) exit (0);
				p++;
				dword = 0;
				for (unsigned b=0; b<8; b++)
				{
					dword <<= 4;
					if (*(p++) == '1')
						dword |= 1;
				}
				printf ("    .BYTE  ");
				printf ("$%02X, $%02X, $%02X, $%02X\n", 
								(dword>>24)&0xff, (dword>>16)&0xff, (dword>>8)&0xff, dword&0xff);
			}
		}
		
		fgets (buf, 1024, fp);
	}
	
	fclose (fp);
}

int pictures (void)
{
	FILE *fp = fopen ("pictures.asm", "rt");
	if (!fp)
		exit (0);
	
	char buf[1024];
		
	fgets (buf, 1024, fp);
	while (!feof (fp))
	{
		//printf ("%s", buf);
		
		if (!strncmp (buf, "shape_", 6))
		{
			char *p = buf;
			while (!isspace (*p))
				p++;
			sprintf (p, ":");
			printf ("%s\n", buf);
			unsigned long dword[2] = { 0, 0 };
			for (unsigned i=0; i<16; i++)
			{
				fgets (buf, 1024, fp);
				p = buf;
				for (unsigned g=0; g<2; g++)
				{
					// convert 1bpp to 4bpp
					p = strchr (p, '%');
					if (!p) exit (0);
					p++;
					dword[g] = 0;
					for (unsigned b=0; b<8; b++)
					{
						dword[g] <<= 4;
						if (*(p++) == '1')
							dword[g] |= 1;
					}
				}
				printf ("    .BYTE  ");
				printf ("$%02X, $%02X, $%02X, $%02X, ", 
								(dword[0]>>24)&0xff, (dword[0]>>16)&0xff, (dword[0]>>8)&0xff, dword[0]&0xff);
				printf ("$%02X, $%02X, $%02X, $%02X\n", 
								(dword[1]>>24)&0xff, (dword[1]>>16)&0xff, (dword[1]>>8)&0xff, dword[1]&0xff);
			}
		}
		
		fgets (buf, 1024, fp);
	}
	
	fclose (fp);
}

int main (int argc, char *argv[])
{
	char_pics ();
	pictures ();
}

