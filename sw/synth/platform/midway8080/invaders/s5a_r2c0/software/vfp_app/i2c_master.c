#include <stdlib.h>
#include <ctype.h>
#include <unistd.h> //usleep

#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include <sys/alt_cache.h>
#include <io.h>
#include <time.h>

// Local Includes
#include <system.h>
#include "veb.h"
#include "i2c_master.h"

#ifndef BUILD_MINIMAL
#include <stdio.h>
#endif

//#define PRINT(format, ...)					printf (format, ## __VA_ARGS__);
#define PRINT(format, ...)

#define EOL     "\n"

int i2c_read_bytes (uint32_t bus, unsigned int dev, unsigned int addr, uint8_t *bytes, unsigned int n)
{
    int             result = I2C_ERROR;
    unsigned int    i;
    unsigned int    data;
    unsigned char   page;

    // random read requires a 'dummy' write

    // shift device address up 1 bit
    dev <<= 1;

    // set the page (P0) bit as 17th bit of address
    #ifdef I2C_USE_16_BIT_ADDR
      #error "I2C_USE_16_BIT_ADDR defined"
      page = (unsigned char)((addr >> 15) & (1<<1));
    #else
    	// set the page (P0,1) bits as 9,10th bits of address
      page = (unsigned char)((addr >> 7) & (3<<1));
    #endif

    do
    {
      // read a byte from the I2C
      I2C_WR32(bus, REG_I2C_TXR, 0x00|dev|page);   // device addr (W)
      I2C_WR32(bus, REG_I2C_CR, 0x90);             // STA, WR
      WAIT_FOR_TIP_AND_ACK(bus, data);
  
      #ifdef I2C_USE_16_BIT_ADDR
        I2C_WR32(bus, REG_I2C_TXR, addr >> 8);     // addr hi
        I2C_WR32(bus, REG_I2C_CR, 0x10);           // WR
        WAIT_FOR_TIP_AND_ACK(bus, data);
      #endif
  
      I2C_WR32(bus, REG_I2C_TXR, addr & 0xFF);     // addr low
      I2C_WR32(bus, REG_I2C_CR, 0x10);             // WR
      WAIT_FOR_TIP_AND_ACK(bus, data);
  
      I2C_WR32(bus, REG_I2C_TXR, 0x01|dev|page);   // device addr (R)
      I2C_WR32(bus, REG_I2C_CR, 0x90);             // STA, WR
      WAIT_FOR_TIP_AND_ACK(bus, data);

      for (i=0; i<n; i++, addr++)
      {
        I2C_WR32(bus, REG_I2C_CR, 0x20);          // RD, ACK
        usleep (1000);

        // and now read the data
        data = I2C_RD32(bus, REG_I2C_RXR);
  
        // and now read the data
        *(bytes++) = I2C_RD32(bus, REG_I2C_RXR);
      }
      
      result = I2C_OK;

    } while (0);

    I2C_WR32(bus, REG_I2C_CR, 0x68);              // STO, RD, NACK
    usleep (1000);

    return (result);
}

int i2c_write_byte (uint32_t bus, unsigned int dev, unsigned int addr, unsigned int data)
{
    int             result = I2C_ERROR;

    unsigned int    status;
    unsigned char   page;

    // shift device address up 1 bit
    dev <<= 1;

    data &= 0xFF;

    // set the page (P0) bit as 17th bit of address
    #ifdef I2C_USE_16_BIT_ADDR
      page = (unsigned char)((addr >> 15) & (1<<1));
    #else
      page = 0;
    #endif

    do
    {
      // write a byte to the I2C
      I2C_WR32(bus, REG_I2C_TXR, 0x00|dev|page);   // device addr (W)
      I2C_WR32(bus, REG_I2C_CR, 0x90);             // STA, WR
      WAIT_FOR_TIP_AND_ACK(bus, status);
  
      #ifdef I2C_USE_16_BIT_ADDR
        I2C_WR32(bus, REG_I2C_TXR, addr >> 8);     // addr hi
        I2C_WR32(bus, REG_I2C_CR, 0x10);           // WR
        WAIT_FOR_TIP_AND_ACK(bus, status);
      #endif
  
      I2C_WR32(bus, REG_I2C_TXR, addr & 0xFF);     // addr low
      I2C_WR32(bus, REG_I2C_CR, 0x10);             // WR
      WAIT_FOR_TIP_AND_ACK(bus, status);
  
      I2C_WR32(bus, REG_I2C_TXR, data);            // data
      I2C_WR32(bus, REG_I2C_CR, 0x10);             // WR
      WAIT_FOR_TIP_AND_ACK(bus, status);
  
      I2C_WR32(bus, REG_I2C_CR, 0x40);             // STO

      result = I2C_OK;

    } while (0);

    usleep (10000);

    return (result);
}

// NOTE: this needs to be modified!!!
void i2c_dump (uint32_t bus, int dev, int addr)
{
    unsigned int    data;
    unsigned char   page;
    char            ascii[16+1];
    int             i;

    // shift device address up by 1 bit
    dev <<= 1;

    // null-terminate the ASCII buffer
    ascii[16] = '\0';

    INIT_I2C(bus, PRESCALE_100kHz);

    // sequential read requires a 'dummy' write

    // start on 16-bit bounday, 128KB range
    addr &= 0x1FFF0;

    #ifdef I2C_USE_16_BIT_ADDR
      // set the page (P0) bit as 17th bit of address
      page = (unsigned char)((addr >> 15) & (1<<1));
    #else
      // set the page (P0) bit as 9th bit of address
      page = (unsigned char)((addr >> 7) & (1<<1));
    #endif

    do
    {
      // read a byte from the I2C
      I2C_WR32(bus, REG_I2C_TXR, 0xa0|dev|page);   // device addr (W)
      I2C_WR32(bus, REG_I2C_CR, 0x90);             // STA, WR
      WAIT_FOR_TIP_AND_ACK(bus, data);
  
      #ifdef I2C_USE_16_BIT_ADDR
        I2C_WR32(bus, REG_I2C_TXR, addr >> 8);     // addr hi
        I2C_WR32(bus, REG_I2C_CR, 0x10);           // WR
        WAIT_FOR_TIP_AND_ACK(bus, data);
      #endif
  
      I2C_WR32(bus, REG_I2C_TXR, addr & 0xFF);     // addr low
      I2C_WR32(bus, REG_I2C_CR, 0x10);             // WR
      WAIT_FOR_TIP_AND_ACK(bus, data);
  
      I2C_WR32(bus, REG_I2C_TXR, 0xa1|dev|page);   // device addr (R)
      I2C_WR32(bus, REG_I2C_CR, 0x90);             // STA, WR
      WAIT_FOR_TIP_AND_ACK(bus, data);
  
      for (i=0; i<256; i++, addr++)
      {
          if ((addr&15) == 0) PRINT ("%05X   ", addr);
  
          I2C_WR32(bus, REG_I2C_CR, 0x20);        // RD, ACK
          usleep (1000);
  
          // and now read the data
          data = I2C_RD32(bus, REG_I2C_RXR);
          PRINT ("0x%02X,", data);
          ascii[addr&15] = (isprint(data) ? data : '.');
  
          if ((addr&15) == 15) PRINT ("%15.15s" EOL, ascii);
  
          // wrap at 128KB boundary
          addr &= 0x1FFFF;
      }
    } while (0);
      
    I2C_WR32(bus, REG_I2C_CR, 0x68);            // STO, RD, NACK
    usleep (1000);
}

#if 0
static char *I2C_TIMEOUT_STR = "I2C timeout: ";

int test_i2c (int verbose)
{
  // there is 1 I2C device on the 'I2C' bus
  // - device address A2..A0 is 0 pre-revA, 4 on revA
  // there are 2 I2C devices on the 'E2' bus
  // - device address A2..A0 are 4 & 6
  static uint32_t bus_addr[] = { E2_BUS_ADDR, I2C_BUS_ADDR };
  static char bus_name[] = { 'E', 'I' };
  static uint8_t bus[] = { 0, 0, 1 };
  static uint8_t dev[] = { 4, 6, 4 };
  #define NUM_DEVICES (sizeof(dev)/sizeof(uint8_t))

  static uint32_t i2c_lfsr = 0x12345678;
  uint8_t wr_data;
  uint8_t rd_data;

  int result = I2C_OK;
  int i, d;

  INIT_I2C (E2_BUS_ADDR, PRESCALE_400kHz);
  INIT_I2C (I2C_BUS_ADDR, PRESCALE_100kHz);

  SEED_LFSR (i2c_lfsr);

#ifdef I2C_DESTRUCTIVE_TEST
  for (d=0; d<NUM_DEVICES; d++)
  {
    uint8_t bus_no = bus[d];

    i2c_lfsr = CLK_LFSR ();
    wr_data = (uint8_t)(i2c_lfsr >> ((d+1)<<3));

    //DISP_INF ("I2C WR: d=%d, a=$%02X, w=$%02X" EOL, d, addr, wr_data);

    if (i2c_write_byte (bus_addr[bus[d]], dev[d], addr, wr_data) != I2C_OK)
    {
      DISP_ERR ("%sb=%c d=%d" EOL, I2C_TIMEOUT_STR, bus_name[bus_no], dev[d]);
      result = I2C_ERROR;
    }
  }
#endif

  for (d=0; d<NUM_DEVICES; d++)
  {
    uint8_t bus_no = bus[d];

    // test 3 different addresses per device
    for (i=0; i<3; i++)
    {
      i2c_lfsr = CLK_LFSR ();
      uint8_t addr = (uint8_t)i2c_lfsr;

      wr_data = (uint8_t)(i2c_lfsr >> ((d+1)<<3));

      if (i2c_read_byte (bus_addr[bus_no], dev[d], addr, &rd_data) != I2C_OK
      #ifdef EMULATE_ERROR
          || d==1
      #endif
      )
      {
        DISP_ERR ("%sb=%c d=%d" EOL, I2C_TIMEOUT_STR, bus_name[bus_no], dev[d]);
        result = I2C_ERROR;
        break;  // next device
      }
#ifdef I2C_DESTRUCTIVE_TEST
      if (rd_data != wr_data)
      {
        DISP_ERR ("I2C failed: b=%c d=%d a=$%02X w=$%02X r=$%02X" EOL, 
                    bus_name[bus_no], dev[d], addr, wr_data, rd_data);
        result = I2C_ERROR;
        break;  // next device
      }
      //DISP_INF ("I2C RD: d=%d, a=$%02X, r=$%02X" EOL, d, addr, rd_data);
#endif
    }
  }

  #ifdef INCLUDE_I2C_DUMP
    //i2c_dump (E2_BUS, 4, 0);
    //i2c_dump (E2_BUS, 6, 0);
  #endif

  return (result);
}
#endif
