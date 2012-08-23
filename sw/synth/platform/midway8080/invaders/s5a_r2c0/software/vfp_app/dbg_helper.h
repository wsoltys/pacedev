#ifndef __DBG_HELPER_H__
#define __DBG_HELPER_H__

#include <stdint.h>

#ifndef DBG_LVL
#define DBG_LVL 0
#endif

#ifdef BUILD_INCLUDE_DEBUG
#include <stdio.h>
#define PRINT(lvl, format...)					do { if(lvl==0 || lvl==DBG_LVL) printf (format); } while(0)
#define DUMP(buf...)                  dump(buf)
#else
#define PRINT(lvl, format...)
#define DUMP(buf...)
#endif

// spi_helper.c
#define SPI_DBG_LVL         0
// ts_helper.c
#define TS_DBG_LVL          0
#define TS_COORD_DBG_LVL    1
#define TS_CALIB_DBG_LVL    1
// ee_helper.h
#define EE_DBG_LVL          1
// ddc_helper.c
#define DDC_DBG_LVL         1
// misc.c
#define MISC_DBG_LVL        1
// vip_helper.c
#define VIP_DBG_LVL         4


char *itoah (uint32_t data, int nibbles, char *buf);
char *itoad (uint32_t data, char *buf);
void dump (uint8_t *data, int len);

/*
 * Control the debug port. All calls are interrupt safe.
 */
typedef enum
{
  dbg_port_normal,
  dbg_port_uh_mon,
  dbg_port_other
} dbg_port_mode;

#define DBG_PORT_ALL_LEDS (0x1ff)
#define DBG_PORT_LED(_l)  (1 << (_l))

void dbg_port_set_mode (dbg_port_mode mode);
void dbg_port_leds_on (uint32_t mask);
void dbg_port_leds_off (uint32_t mask);
void dump_heap_info (void);

void debug_shell (void);

#endif
