#ifndef __I2C_MASTER_H__
#define __I2C_MASTER_H__

#include <stdint.h>

//#define I2C_USE_16_BIT_ADDR

#define I2C_RD32(bus, addr)            \
  IORD_8DIRECT ((bus), (addr))
#define I2C_WR32(bus, addr, data)      \
  IOWR_8DIRECT ((bus), (addr), (data))

#define I2C_ERROR   -1
#define I2C_OK      0

#define REG_I2C_PRERlo              (0<<0)
#define REG_I2C_PRERhi              (1<<0)
#define REG_I2C_CTR                 (2<<0)
#define REG_I2C_TXR                 (3<<0)
#define REG_I2C_RXR                 REG_I2C_TXR
#define REG_I2C_CR                  (4<<0)
#define REG_I2C_SR                  REG_I2C_CR

// set divisor and enable
//
// prescale = sys_clk / (5 * i2c_clk) - 1
//
// - @112MHz = $37
// - @132MHz = $41
// - @66.7MHz = $20 (400kHz) $84 (100kHz)
// - @108MHz = 53=$35 (400kHz) 215=$D7 (100kHz)

//#define PRESCALE_100kHz   0xD7
#define PRESCALE_100kHz   0xF0
#define PRESCALE_400kHz   0x35

#define INIT_I2C(bus, prescale)               \
{                                             \
    I2C_WR32(bus, REG_I2C_CTR, 0x00);         \
    I2C_WR32(bus, REG_I2C_PRERlo, prescale);  \
    I2C_WR32(bus, REG_I2C_PRERhi, 0x00);      \
    I2C_WR32(bus, REG_I2C_CTR, 0x80);         \
}

#define WAIT_FOR_TIP_AND_ACK(bus, x)                  \
{                                                     \
  int i2c_timeout = 100000;                             \
  do                                                  \
  {                                                   \
    x = I2C_RD32(bus, REG_I2C_SR);                    \
    /*usleep (100);*/                                     \
                                                      \
  } while (--i2c_timeout && (x & ((1<<1)|(1<<7))));   \
  if (i2c_timeout == 0) break;                        \
}

int i2c_read_bytes (uint32_t bus, unsigned int dev, unsigned int addr, uint8_t *bytes, unsigned int n);
int i2c_write_byte (uint32_t bus, unsigned int dev, unsigned int addr, unsigned int data);
void i2c_dump (uint32_t bus, int dev, int addr);

#endif //__I2C_MASTER_H__

