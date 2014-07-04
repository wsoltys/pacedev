#ifndef NO_STDIO
  #include <stdio.h>
#endif
#include <stdlib.h>

#include "osd_types.h"
#include "lr_osd.h"

extern uint8_t level_data_packed[256];
extern uint8_t ldu1[16][28];
extern uint8_t ldu2[16][28];

void dbg_dump_level_packed (void)
{
  unsigned  r, c;
  
  for (r=0; r<16; r++)
  {
    for (c=0; c<28/2; c++)
      OSD_PRINTF ("%d %d ", 
                level_data_packed[r*28/2+c] & 0x0f,
                level_data_packed[r*28/2+c] >> 4);
    OSD_PRINTF ("\n");
  }
}

void dbg_dump_level (int dyn_or_static)
{
  unsigned  r, c;

  for (r=0; r<16; r++)
  {
    for (c=0; c<28; c++)
    {
      OSD_PRINTF ("%d ", 
                (dyn_or_static == 1
                  ? ldu1[r][c]
                  : ldu2[r][c]));
    }
    OSD_PRINTF ("\n");
  }
}
