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
    
  do
  {
    uint8_t cmd = *(p+1) >> 4;
    uint16_t offset = (p-buf);
    
    switch (cmd)
    {
      // vec
      case 0x00 : case 0x01 : case 0x02 : case 0x03 :
      case 0x04 : case 0x05 : case 0x06 : case 0x07 :
      case 0x08 : case 0x09 :
        printf ("$%04X: VEC\n", offset);
        p += 4;
        break;
      // cur
      case 0x0A :
        printf ("$%04X: CUR\n", offset);
        p += 4;
        break;
      // halt
      case 0x0B :
        printf ("$%04X: HALT\n", offset);
        done = true;
        break;
      // jsr
      case 0x0C :
        printf ("$%04X: JSR\n", offset);
        p += 2;
        break;
      // rts
      case 0x0D :
        printf ("$%04X: RTS\n", offset);
        p += 2;
        break;
      // jmp
      case 0x0E :
        printf ("$%04X: JMP\n", offset);
        p += 2;
        break;
      // svec
      case 0x0F :
        printf ("$%04X: SVEC\n", offset);
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
}
