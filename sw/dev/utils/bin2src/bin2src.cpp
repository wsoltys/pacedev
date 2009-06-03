#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

void usage (char *argv0)
{
	fprintf (stderr, "usage: %s -{b|c} <infile>\n", argv0);
	fprintf (stderr, "  options:\n");
	fprintf (stderr, "    -b    BASIC\n");
	fprintf (stderr, "    -c    C/C++\n");

	exit (1);
}

typedef enum { eNONE=0, eBASIC, eC } eLANGUAGE;

int main (int argc, char *argv[])
{
	char *filename = 0;
	eLANGUAGE language = eNONE;

	while (--argc)
	{
		switch (argc[argv][0])
		{
			case '/' :
			case '-' :
				switch (tolower(argv[argc][1]))
				{
					case 'b' :
						language = eBASIC;
						break;
					case 'c' :
						language = eC;
						break;
					default :
						usage (argv[0]);
						break;
				}
				break;
			default :
				filename = argv[argc];
				break;
		}
	}

	if (!filename || language == eNONE)
		usage (argv[0]);

	FILE *fp = fopen (filename, "rb");
	if (!fp)
	{
		fprintf (stderr, "error: unable to open input file \"%s\"!\n", filename);
		exit (1);
	}

	switch (language)
	{
		case eC :
			printf ("unsigned char dat[] = \n");
			printf ("{\n");
			break;
		default :
			break;
	}

	unsigned int count = 0;
	while (!feof(fp))
	{
		unsigned char byte;

		if (count % 16 == 0)
			switch (language)
			{
				case eBASIC :
					printf ("DATA ");
					break;
				case eC :
					printf ("  ");
					break;
				default :
					break;
			}

		int n = fread (&byte, 1, 1, fp);
		if (!n)
			break;

		switch (language)
		{
			case eBASIC :
				printf ("&H%02X%c ", byte, (count %16 == 15 ? ' ' : ','));
				break;
			case eC :
				printf ("0x%02X, ", byte);
				break;
			default :
				break;
		}

		if (count % 16 == 15)
			printf ("\n");

		++count;
	}
	if ((count % 16) != 15)
		printf ("\n");

	switch (language)
	{
		case eC :
			printf ("};\n");
			printf ("\n");
			printf ("#define DAT_BYTES (sizeof(dat)/sizeof(unsigned char))\n");
			break;
		default :
			break;
	}

	fprintf (stderr, "%d bytes read\n", count);
	fclose (fp);
}
