#include <stdio.h>
#include <stdlib.h>

//    return crc_i(14 downto 12) & (dat_i xor crc_i(11) xor crc_i(15)) & crc_i(10 downto 5) &
//            (dat_i xor crc_i(4) xor crc_i(15)) & crc_i(3 downto 0) & (dat_i xor crc_i(15));

#define BIT(n)  (1<<(n))

unsigned short int crc16 (unsigned short int d, unsigned short int crc)
{
  unsigned short int tmp;
  unsigned short int d15 = d ^ ((crc&BIT(15))>>15);

  // maybe CRC works with negated data???
  //d15 ^= 1;

  tmp = crc & (BIT(14)|BIT(13)|BIT(12)|BIT(10)|BIT(9)|BIT(8)|BIT(7)|BIT(6)|BIT(5)|BIT(3)|BIT(2)|BIT(1)|BIT(0));
  tmp <<= 1;
  tmp |= ((crc & BIT(11)) ^ (d15<<11)) << 1;
  tmp |= ((crc & BIT(4)) ^ (d15<<4)) << 1;
  tmp |= d15;

  return (tmp);
}

/* Slow way, not using table */
unsigned short CALC_CRC1a(unsigned short crc, unsigned char byte)
{
  int i = 8;
  unsigned short b = byte << 8;
  while (i--) {
    crc = (crc << 1) ^ (((crc ^ b) & 0x8000) ? 0x1021 : 0);
    b <<= 1;
  }
  return crc;
}

typedef unsigned short int UINT16;
typedef unsigned char UINT8;

static void calc_crc(UINT16 * crc, UINT8 value)
{
	UINT8 l, h;

	l = value ^ (*crc >> 8);
	*crc = (*crc & 0xff) | (l << 8);
	l >>= 4;
	l ^= (*crc >> 8);
	*crc <<= 8;
	*crc = (*crc & 0xff00) | l;
	l = (l << 4) | (l >> 4);
	h = l;
	l = (l << 2) | (l >> 6);
	l &= 0x1f;
	*crc = *crc ^ (l << 8);
	l = h & 0xf0;
	*crc = *crc ^ (l << 8);
	l = (h << 1) | (h >> 7);
	l &= 0xe0;
	*crc = *crc ^ l;
}

#define BITOF(d,n)  ((d)&BIT(n))
#define BITSOF(d,n) (BITOF(d,n)>>n)

int main(int argc, char *argv)
{
  unsigned short int crc;
  unsigned char data[] = { 0xA1, 0xA1, 0xA1, 0xFE, 0x00, 0x00, 0x0A, 0x01 };
  #define N_BYTES (sizeof(data)/sizeof(unsigned char))
  #define START 0

  printf ("Serial (PACE)\n");
  crc = 0xFFFF;
  for (int i=START; i<N_BYTES; i++)
  {
    for (int b=0; b<8; b++)
    {
      unsigned char d = data[i];

      crc = crc16 ((d>>(7-b)) & 1, crc);
      //crc = crc16 ((d>>i) & 1, crc);
      printf ("(%d)%04X ", (d>>(7-b))&1, crc);
    }
    printf ("\n");
  }
  printf ("\n");

  printf ("JV2DMK (slow)\n");
  crc = 0xFFFF;
  for (int i=START; i<N_BYTES; i++)
  {
    unsigned char d = data[i];

    crc = CALC_CRC1a (crc, d);    
    printf ("%04X\n", crc);
  }
  printf ("\n");

  printf ("MESS\n");
  crc = 0xFFFF;
  for (int i=START; i<N_BYTES; i++)
  {
    unsigned char d = data[i];

    // reverse the bits
    //d=(BITSOF(d,7)<<0)|(BITSOF(d,6)<<1)|(BITSOF(d,5)<<2)|(BITSOF(d,4)<<3)|
    //  (BITSOF(d,3)<<4)|(BITSOF(d,2)<<5)|(BITSOF(d,1)<<6)|(BITSOF(d,0)<<7);
    calc_crc (&crc, d);    
    printf ("%04X\n", crc);
  }
}
