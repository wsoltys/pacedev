
#ifndef __OW_H__
#define __OW_H__

#include <alt_types.h>

#define OW_RESULT_OK              0
#define OW_ERROR_NO_DEVICE     1000
#define OW_CRC_ERROR           1001
#define OW_DATA_ERROR          1002


// ow_base - base address of one wire sopc component
// romid   - 8 byte buffer where to put the read out rom id
// Result: 0=OK, non-zero indicates error as defined above
int ow_read_romid(alt_u32 ow_base, alt_u8 * romid);




#endif
