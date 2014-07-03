#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern uint8_t level_data_packed[256];
extern uint8_t ldu1[16][28];
extern uint8_t ldu2[16][28];

void dbg_dump_level_packed (void)
{
  for (unsigned r=0; r<16; r++)
  {
    for (unsigned c=0; c<28/2; c++)
      fprintf (stderr, "%d %d ", 
                level_data_packed[r*28/2+c] & 0x0f,
                level_data_packed[r*28/2+c] >> 4);
    fprintf (stderr, "\n");
  }
}

void dbg_dump_level (int dyn_or_static)
{
  for (unsigned r=0; r<16; r++)
  {
    for (unsigned c=0; c<28; c++)
    {
      fprintf (stderr, "%d ", 
                (dyn_or_static == 1
                  ? ldu1[r][c]
                  : ldu2[r][c]));
    }
    fprintf (stderr, "\n");
  }
}
