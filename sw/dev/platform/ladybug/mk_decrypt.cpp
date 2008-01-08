#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
  int i;
  char buf[256];

  FILE *fp = fopen ("decrypt_l.bin", "wb");
  for (i=0; i<256; i++)
  {
    buf[0] = i & 0x0f;
    fwrite (buf, 1, 1, fp);
  }
  fclose (fp);

  fp = fopen ("decrypt_u.bin", "wb");
  for (i=0; i<256; i++)
  {
    buf[0] = (i & 0xf0) >> 4;
    fwrite (buf, 1, 1, fp);
  }
  fclose (fp);
}

#if 0
#!/usr/bin/perl -w

use strict;

my $i;

if (scalar(@ARGV) != 1) {
    print(STDERR "Usage: $0 <l|u>\n");
    exit 1;
} else {
    if (!($ARGV[0] eq "l" || $ARGV[0] eq "u")) {
        print(STDERR "Argument must be l or u\n");
    }
}

for ($i = 0; $i < 256; $i++) {
    if ($ARGV[0] eq "l") {
        print(pack("C", $i & 0x0f));
    } elsif ($ARGV[0] eq "u") {
        print(pack("C", ($i & 0xf0) >> 4));
    }
}
#endif
