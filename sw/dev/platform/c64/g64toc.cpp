#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct g64_hdr_t
{
  char            signature[8];
  unsigned char   version;
  unsigned char   tracks;
  unsigned short  track_size;

} G64_HDR, *PG64_HDR;

void usage (char *argv0)
{
  char *p = strrchr (argv0, ',');
  if (!p) p = argv0;

  fprintf (stderr, "usage %s <filename>[.G64]\n", p);

  exit (0);
}

void dump (unsigned char *buf, int n)
{
  int i;

  for (i=0; i<n; i++)
  {
    if (i%16 == 0) printf ("  ");
    printf ("0x%02X, ", buf[i]);
    if (i%16 == 15) printf ("\n");
  }
  if (i%16 != 0) printf("\n");
}

int main (int argc, char *argv[])
{
  G64_HDR hdr;
  unsigned long int trkoff[84];
  unsigned char trkbuf[16384];
  unsigned char *p;

  fpos_t pos;

  if (--argc < 1)
    usage (argv[0]);

  FILE *fp = fopen (argv[1], "rb");
  if (!fp) exit (0);

  fread (&hdr, sizeof(G64_HDR), 1, fp);

  fprintf (stderr, "%20.20s = \"%8.8s\"\n", "signature", hdr.signature);  
  fprintf (stderr, "%20.20s = %d\n", "version", (int)hdr.version);  
  fprintf (stderr, "%20.20s = %d\n", "tracks", (int)hdr.tracks);  
  fprintf (stderr, "%20.20s = %d\n", "track_size", (int)hdr.track_size);  

  if (strncmp (hdr.signature, "GCR-1541", 8)) exit (0);

  printf ("#ifdef _IS_INCLUDED_\n\n");

  // start creating the file
  printf (""
    "typedef struct g64_hdr_t\n"
    "{\n"
    "  char            signature[8];\n"
    "  unsigned char   version;\n"
    "  unsigned char   tracks;\n"
    "  unsigned short  track_size;\n"
    " \n"
    "} G64_HDR, *PG64_HDR;\n"
    "\n"
  );

  printf ("unsigned char g64_data[] = \n"
          "{\n");

  printf ("  // G64_HDR g64_hdr = { \"%8.8s\", %d, %d, %d };\n\n",
          hdr.signature, (int)hdr.version, (int)hdr.tracks, (int)hdr.track_size);
  dump ((unsigned char *)&hdr, sizeof(G64_HDR));
  printf ("\n");

  int n;

  printf ("  // TRACK OFFSET info\n\n");
  n = fread (&trkoff, 1, hdr.tracks*sizeof(unsigned long), fp);
  dump ((unsigned char *)&trkoff, n);
  printf ("\n");

  printf ("  // SPEED ZONE info\n\n");
  n = fread (trkbuf, 1, hdr.tracks*sizeof(unsigned long), fp);
  dump (trkbuf, n);
  //printf ("\n");

  int t = 0;
  while (!feof(fp))
  {
    while (t < hdr.tracks && trkoff[t] == 0)
      t++;

    if (t == hdr.tracks) break;

    fgetpos (fp, &pos);
    if ((n = (trkoff[t]-pos)) > 0)
    {
      fread (trkbuf, 1, n, fp);
      printf ("  //padding %d bytes\n", n);
      dump (trkbuf, n);
    }
    printf ("\n");

    if (feof (fp)) break;

    printf ("  // TRACK %d.%d\n", t/2+1, (t%2)*5);

    int n = fread (trkbuf, 1, hdr.track_size, fp);
    dump (trkbuf, n);

    //if (t==16) break;

    t++;
  }

  if (!feof (fp))
    if ((n = fread (trkbuf, 1, hdr.track_size, fp)) > 0)
    {
      printf ("  //padding %d bytes\n", n);
      dump (trkbuf, n);
    }

  printf ("};\n");

  printf ("\n#endif // _IS_INCLUDED\n");

  fclose (fp);

  fprintf (stderr, "Done!\n");
}
