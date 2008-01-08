#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE_16K	(16*1024)
#define SIZE_32K	(32*1024)
#define SIZE_64K	(64*1024)

unsigned char mem[SIZE_64K];

int main (int argc, char *argv[])
{
	char szFile[_MAX_PATH], *p;
	FILE *fp;

	--argc;
	switch (argc)
	{
		case 0 :
			strcpy (szFile, "mem.dump");
			break;
		case 1 :
			strcpy (szFile, argv[1]);
			break;
		default :
			printf ("usage: mkram [<dumpfile>]\n");
			exit (0);
			break;
	}
	
	fp = fopen (szFile, "rb");
	if (!fp) exit (1);
	fread (mem, sizeof(unsigned char), SIZE_64K, fp);
	fclose (fp);

	if ((p = strrchr (szFile, '.')) != 0) *p = '\0';
	strcat (szFile, "4.bin");
	fp = fopen (szFile, "wb");
	if (!fp) exit (1);
	fwrite (&mem[SIZE_16K], sizeof(unsigned char), SIZE_16K, fp);
	fclose (fp);
	
	if ((p = strrchr (szFile, '.')) != 0) *(p-1) = '\0';
	strcat (szFile, "8.bin");
	fp = fopen (szFile, "wb");
	if (!fp) exit (1);
	fwrite (&mem[SIZE_32K], sizeof(unsigned char), SIZE_32K, fp);
	fclose (fp);
}
