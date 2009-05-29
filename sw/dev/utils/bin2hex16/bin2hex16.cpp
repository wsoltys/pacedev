#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#define SWAP(x) (((x)>>8)|((x&0xFF)<<8))

void usage (char *argv0)
{
  fprintf (stderr, "usage: %s [-s] [-o] <filename>\n", argv0);
  fprintf (stderr, "  options:\n");
  fprintf (stderr, "    -o    offset (default=0)\n");
  fprintf (stderr, "    -s    byte-swap input\n");

  exit (0);
}

int main (int argc, char *argv[])
{
  long offset = 0;
  char *filename = 0;
  bool swap = false;

	while(--argc)
  {
    switch (argv[argc][0])
    {
      case '/' :
      case '-' :
        switch (tolower(argv[argc][1]))
        {
          case 'o' :
            offset = atol(&argv[argc][2]);
            break;
          case 's' :
            swap = true;
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

  fprintf (stderr, "filename=\"%s\"\n", filename);
  fprintf (stderr, "swap=%d\n", (swap ? 1 : 0));
  fprintf (stderr, "offset=%d\n", offset);

  if (!filename)
    usage (argv[0]);

	unsigned short int a = 0;
	
	FILE *fp = fopen (filename, "rb");
  if (!fp)
    exit (0);

  fseek (fp, offset, SEEK_SET);

	while (!feof (fp))
	{
		unsigned short int d;
		unsigned char cs;

		fread (&d, 1, 2, fp);
		if (swap)
      d = SWAP(d);

		cs = 0;
		cs += 2;
		cs += (a>>8);
		cs += a & 0xFF;
		cs += (d>>8);
		cs += d & 0xFF;
		cs = -cs;

		// :<bytecount=02><addr=XXXX><rectype=00><data=XXXX><checksum>
		printf (":02%04X00%04X%02X\n", a, d, cs);
		a++;
	}
	fclose (fp);

	printf (":00000001FF\n");

}

/*
:020000000010EE
:020001007FFF7F
:0200020000F00C
:020003000400F7
:020004000000FA
:020005000000F9
:020006000000F8
:020007000000F7
:020008000000F6
:020009000000F5
:02000A000000F4
:02000B000000F3
:02000C000000F2
:02000D000000F1
:02000E000000F0
*/
