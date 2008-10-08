#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

int n_tracks = 40;
unsigned char trkbuf[8*1024];

typedef enum
{
  UNKNOWN, 
  GAP2_4E, GAP2_00, GAP2_A1, 
  ID_ADDR_MARK, TRACK, SIDE, SECTOR, SEC_LEN, CRC_1,
  GAP3_4E, GAP3_00, GAP3_A1,
  DAM, USER_DATA, CRC_2

} STATE_t;

unsigned char idam_track;
unsigned char idam_side;
unsigned char idam_sector;
unsigned char idam_seclen;
unsigned short int crc;
unsigned char idam_dam;

#define MIN_GAP2_4E     15
#define MIN_GAP2_00     8

void usage (char *exe)
{
  printf ("usage: %s [-v] <filename>\n");
  printf ("  options:\n");
  printf ("    -v    verbose\n");
  exit (0);
}

int main (int argc, char *argv[])
{
  char *fname = NULL;
  bool bVerbose = false;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' : case '/' :
        switch (tolower(argv[argc][1]))
        {
          case 'v' :
            bVerbose = true;
            break;
          default :
            usage (argv[0]);
            break;
        }
        break;
      default:
        fname = argv[argc];
        break;
    }
  }
  if (!fname) usage(argv[0]);

  FILE *fp = fopen (fname, "rb");
  if (!fp) exit (0);

  for (int t=0; t<n_tracks; t++)
  {
    int n = fread (trkbuf, 1, 8*1024, fp);
    if (n != 8*1024)
      break;

    int n_secs = 0;

    //fprintf (stderr, "TRK=%d\n",  t);
    int i = 0;
    STATE_t state = UNKNOWN;
    int count = 0;
    while (i < 8*1024)
    {
      if (state == UNKNOWN)
      {
        count = 0;
        state = GAP2_4E;
      }
      else
      {
        switch (state)
        {
					case GAP2_4E :
						// at least 22 bytes of $4E
						if (trkbuf[i] == 0x4E)
            {
							if (count < MIN_GAP2_4E)
								count = count + 1;
            }
						else if (trkbuf[i] == 0x00 && count == MIN_GAP2_4E)
            {
							count = 1;
							state = GAP2_00;
            }
						else
							state = UNKNOWN;
            break;
					case GAP2_00 :
						// exactly 12 bytes of $00
						if (trkbuf[i] == 0x00)
            {
              if (count < MIN_GAP2_00)
							  count = count + 1;
            }
            else if (trkbuf[i] == 0xA1 && count == MIN_GAP2_00)
            {
							count = 1;
							state = GAP2_A1;
            }
						else
							state = UNKNOWN;
            break;
					case GAP2_A1 :
						// exactly 3 bytes of $A1
						if (trkbuf[i] == 0xA1)
            {
							count = count + 1;
							if (count == 3)
								state = ID_ADDR_MARK;
            }
						else
							state = UNKNOWN;
            break;
					case ID_ADDR_MARK :
						if (trkbuf[i] == 0xFE)
							state = TRACK;
						else
							state = UNKNOWN;
						break;
					case TRACK :
						idam_track = trkbuf[i];
						//data_o_r <= raw_data_r;
						//addr_data_rdy <= '1';
						state = SIDE;
            break;
					case SIDE :
						idam_side = trkbuf[i];
						//data_o_r <= raw_data_r;
						//addr_data_rdy <= '1';
						state = SECTOR;
            break;
					case SECTOR :
						idam_sector = trkbuf[i];
						//data_o_r <= raw_data_r;
						//addr_data_rdy <= '1';
						state = SEC_LEN;
            break;
					case SEC_LEN :
						idam_seclen = trkbuf[i];
						//data_o_r <= raw_data_r;
						//addr_data_rdy <= '1';
						count = 0;
						state = CRC_1;
            break;
					case CRC_1 :
						crc <= (crc << 8) | trkbuf[i];
						//data_o_r <= raw_data_r;
						//addr_data_rdy <= '1';
						count = count + 1;
						if (count == 2)
            {
							// really need to check CRC here first
							//id_addr_mark_rdy <= '1';
              if (bVerbose)
                printf ("TRK=%02d SID=%02d SEC=%02d LEN=%02d\n",
                        idam_track, idam_side, idam_sector, idam_seclen);
							count = 0;
							state = GAP3_4E;
            }
            break;
					case GAP3_4E :
						if (trkbuf[i] == 0x4E)
            {
							if (count < 22)
								count = count + 1;
            }
						else if (trkbuf[i] == 0x00 && count == 22)
            {
							count = 1;
							state = GAP3_00;
            }
						else
							state = UNKNOWN;
						break;
					case GAP3_00 :
						if (trkbuf[i] == 0x00)
            {
							if (count < 8)
								count = count + 1;
            }
						else if (trkbuf[i] == 0xA1 && count == 8)
            {
							count = 1;
							state = GAP3_A1;
            }
						else
							state = UNKNOWN;
						break;
					case GAP3_A1 :
						if (trkbuf[i] == 0xA1)
            {
							count = count + 1;
							if (count == 3)
								state = DAM;
            }
						else
							state = UNKNOWN;
						break;
					case DAM :
						idam_dam = trkbuf[i];
						//data_addr_mark_rdy <= '1';
						count = 0;
						state = USER_DATA;
            break;
					case USER_DATA :
						// reading user sector data
						count = count + 1;
            //data_o_r <= raw_data_r;
            //user_data_rdy <= '1';
						if (count == 256)
            {
							count = 0;
							state = CRC_2;
            }
						break;
					case CRC_2 :
						crc = (crc << 8) | trkbuf[i];
						count = count + 1;
						if (count == 2)
            {
              n_secs++;
							state = UNKNOWN;
            }
						break;
          default:
						state = UNKNOWN;
            break;
        }
        if (bVerbose)
          printf ("i=$%02X, count=%02d, state=%d\n", trkbuf[i], count, state);
        i++;
      }
    }
    printf ("TRK=%02d, nSECs=%02d\n", t, n_secs);
  }

  fprintf (stderr, "Done!\n");
}
