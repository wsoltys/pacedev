#include <stdio.h>
#include <stdlib.h>

int main( int argc, char *argv[])
{
	int size = 1024;

	if (argc == 2)
		size = atoi(argv[1]);

	FILE *fp = fopen ("fn.bin", "wb");
	for (int i=0; i<size; i++)
	{
		unsigned char ch = (unsigned char)i;
		fwrite (&ch, 1, 1, fp);
	}
	fclose (fp);
}
