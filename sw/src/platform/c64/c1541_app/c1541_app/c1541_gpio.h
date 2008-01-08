#ifndef __C1541_GPIO_H__
#define __C1541_GPIO_H__

#define BIT_MASK(b)   (1<<(b))

// inputs to NIOS
// - all bits except MODE correspond to 6522 PB bit assigments

#define _BIT_MODE             7
#define _BIT_FREQ_1           6
#define _BIT_FREQ_0           5
#define _BIT_STP_OUT          4
#define _BIT_STP_IN           3
#define _BIT_MTR              2
#define _BIT_STP_0            1
#define _BIT_STP_1            0
                              
#define C1541_MODE            BIT_MASK(_BIT_MODE)
#define C1541_FREQ            (BIT_MASK(_BIT_FREQ_1)|BIT_MASK(BIT_FREQ_0))
#define C1541_STP_OUT         BIT_MASK(_BIT_STP_OUT)
#define C1541_STP_IN          BIT_MASK(_BIT_STP_IN)
#define C1541_MTR             BIT_MASK(_BIT_MTR)
#define C1541_STP             (BIT_MASK(_BIT_STP_0)|BIT_MASK(_BIT_STP_1))

#define C1541_STP_VAL(x)      (((x)>>_BIT_STP_1)&3)
#define C1541_FREQ_VAL(x)     (((x)>>_BIT_FREQ_0)&3)

// outputs from NIOS
#define _BIT_RESET            7
#define _BIT_SYNC_n           3
#define _BIT_BYTE_n           2
#define _BIT_WPS_n            1
#define _BIT_TR00_SENSE_n     0

#define C1541_RESET           BIT_MASK(_BIT_RESET)
#define C1541_SYNC_n          BIT_MASK(_BIT_SYNC_n)
#define C1541_BYTE_n          BIT_MASK(_BIT_BYTE_n)
#define C1541_WPS_n           BIT_MASK(_BIT_WPS_n)
#define C1541_TR00_SENSE_n    BIT_MASK(_BIT_TR00_SENSE_n)

//
// Notes
//
// MODE is 0=write, 1=read
//

//
// FIFO bits
//

#define _BIT_FIFO_ACLR        1
#define _BIT_FIFO_WRREQ       0

#define FIFO_ACLR             BIT_MASK(_BIT_FIFO_ACLR)
#define FIFO_WRREQ            BIT_MASK(_BIT_FIFO_WRREQ)

#define _BIT_FIFO_WRFULL      8
#define _BIT_FIFO_WRUSEDW_0   0

#define FIFO_WRFULL           BIT_MASK(_BIT_FIFO_WRFULL)
#define FIFO_WRUSEDW_VAL(x)   (((x)>>_BIT_FIFO_WRUSEDW_0)&0xFF)

//
// MECH bits
//

// pio_mech_out (drive_mech_gpi)
#define _BIT_CD_CF            0
#define CD_CF                 BIT_MASK(_BIT_CD_CF)

// pio_mech_in (drive_mech_gpo)
#define _BIT_NON_CF           0
#define NON_CF                BIT_MASK(_BIT_NON_CF)

#endif

