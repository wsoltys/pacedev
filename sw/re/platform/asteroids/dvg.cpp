#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

static uint8_t ram[64*1024];

static void dvg_parse (uint8_t *buf)
{
  uint8_t *p = buf;
  bool done = false;
    
  static char* chrtbl = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  
  do
  {
    uint8_t cmd = *(p+1) >> 4;
    uint16_t offset = (p-buf);
    uint16_t x, y;
    uint8_t s;
    uint16_t a;
    char chr;
    char buf[256];
                
    switch (cmd)
    {
      // vec
      case 0x00 : case 0x01 : case 0x02 : case 0x03 :
      case 0x04 : case 0x05 : case 0x06 : case 0x07 :
      case 0x08 : case 0x09 :
        //   SSSS -mYY YYYY YYYY | BBBB -mXX XXXX XXXX
        //   YYYY YYYY SSSS -mYY | XXXX XXXX BBBB -mXX 
        x = *(p+2) + (((uint16_t)*(p+3) & 0x03) << 8);
        y = *(p+0) + (((uint16_t)*(p+1) & 0x03) << 8);
        sprintf (buf, "$%04X: VEC (%02X%02X %02X%02X)", 
                offset, *(p+1), *(p+0), *(p+3), *(p+2));
        printf ("%-32.32s(%c%d,%c%d)x%d,B=%d\n", buf,
                (*(p+3) & (1<<2) ? '-' : '+'), x,
                (*(p+1) & (1<<2) ? '-' : '+'), y,
                  cmd, *(p+3) >> 4);
        p += 4;
        break;
      // cur
      case 0x0A :
        // 1010 00yy yyyy yyyy | SSSS 00xx xxxx xxxx
        // yyyy yyyy 1010 00yy | xxxx xxxx SSSS 00xx 
        x = *(p+2) + (((uint16_t)*(p+3) & 0x03) << 8);
        y = *(p+0) + (((uint16_t)*(p+1) & 0x03) << 8);
        s = *(p+3) >> 4;
        sprintf (buf, "$%04X: CUR (%02X%02X %02X%02X)", 
                offset, *(p+1), *(p+0), *(p+3), *(p+2));
        printf ("%-32.32s(%d,%d)x%d\n", buf, x, y, s);
        p += 4;
        break;
      // halt
      case 0x0B :
        sprintf (buf, "$%04X: HALT\n", offset);
        printf ("%-32.32s\n", buf);
        done = true;
        break;
      // jsr
      case 0x0C :
        // 1100 aaaa aaaa aaaa
        // aaaa aaaa 1100 aaaa 
        a = *(p+0) + (((uint16_t)*(p+1) & 0x0f) << 8);
        sprintf (buf, "$%04X: JSR (%02X%02X)", offset, *(p+1), *(p+0));
        chr = '.';
        // lookup function
        {
          unsigned i;
          uint16_t base = 0x56d4;
          for (i=0; i<32; i++)
          {
            if (*(p+0) == ram[base+2*i] && *(p+1) == ram[base+2*i+1])
            {
              chr = chrtbl[i];
              break;
            }
          }
        }
        printf ("%-32.32saddr=$%04X '%c'\n", buf, (a<<1)-0x800, chr);
        p += 2;
        break;
      // rts
      case 0x0D :
        sprintf (buf, "$%04X: RTS", offset);
        printf ("%-32.32s\n", buf);
        p += 2;
        break;
      // jmp
      case 0x0E :
        // 1110 aaaa aaaa aaaa
        // aaaa aaaa 1110 aaaa 
        a = *(p+0) + (((uint16_t)*(p+1) & 0x0f) << 8);
        sprintf (buf, "$%04X: JMP (%02X%02X)", offset, *(p+1), *(p+0));
        printf ("%-32.32saddr=$%04X\n", buf, (a<<1));
        p += 2;
        break;
      // svec
      case 0x0F :
        sprintf (buf, "$%04X: SVEC", offset);
        printf ("%-32.32s\n", buf);
        p += 4;
        break;
      default :
        break;
    }
    
  } while (!done);
}

int main (int argc, char *argv[])
{
  FILE *fp = fopen ("ast002.bin", "rb");
	struct stat	fs;
	int					fd;
  if (!fp)
    exit (0);
	fd = fileno (fp);
	if (fstat	(fd, &fs))
		exit (0);
	fread (ram, sizeof(uint8_t), fs.st_size, fp);
	fclose (fp);
	
	dvg_parse (&ram[0x4000]);
	//dvg_parse (&ram[0x4402]);
}
