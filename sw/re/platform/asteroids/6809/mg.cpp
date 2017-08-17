#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main (int argc, char *argv[])
{
	FILE *fp = fopen ("../iigs/bitmaps.asm", "rt");
	char buf[1024];
	char label[64];
	bool new_label = false;
	
	if (!fp)
		exit (0);

	fgets (buf, 1023, fp);
	while (!feof (fp))
	{
		char *p = buf;
		char *q;
				
		if ((q = strchr (buf, ':')))
		{
			while (isspace (*p)) p++;
			*q = 0;
			strcpy (label, p);
			new_label = true;
		}
		else if (strstr (buf, "BYTE") || strstr (buf, "byte"))
		{
			if (new_label)
				printf ("\n%s:\n", label);
			new_label = false;
			
			unsigned bits = 0;
			unsigned shift = 0;
			if (!strcmp (label, "copyright"))
				shift = 4;
			while (1)
			{
				while (*p && *p != '0' && *p != 'F') p++;
				if (!*p) break;
				if (bits == 0) printf ("    .byte ");
				if ((bits%8) == 0) printf ("%s$%%", (bits == 0 ? "" : ", "));
				if (bits < shift)
					printf ("0");
				else
				{
					printf ("%c", *p == 'F' ? '1' : *p);
					p++;
				}
				bits++;
			}
			for(; (bits%8) != 0; bits++)
				printf ("0");
			printf ("\n");
		}

		// for now
		//if (!strcmp (label, "chr_tbl")) break;
			
		fgets (buf, 1023, fp);
	}
		
	fclose (fp);
}
