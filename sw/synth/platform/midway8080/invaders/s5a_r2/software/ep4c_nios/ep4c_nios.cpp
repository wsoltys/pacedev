#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include "system.h"

#include "config.h"

#include "i2c_master.h"

#define TVP7002_A   (0xB8>>1)

int main (int argc, char* argv[], char* envp[])
{
  unsigned char buf[32];

  printf ("PACE S5A_r2 Cyclone Control Software v0.1\n");

  // power-up the TVP7002
  IOWR_ALTERA_AVALON_PIO_DATA (PIO_0_BASE, (0<<0));
  usleep (200000);

  // initialise TVP7002 I2C master
  INIT_I2C(VAI_I2C_MASTER_0_BASE, PRESCALE_400kHz);

  // read the chip revision
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0, buf, 1);
  printf ("Chip Revision = %d\n", buf[0]);

  // 800x600@60Hz
  // PLLDIV[11:4]
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x01, 0x42);
  // PLLDIV[3:0]
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x02, 0x00);
  // VCO RANGE[7:6] (low) CURRENT[5:3] (011b)
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x03, 0x58);
  // Clamp Start (PC graphics)
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x05, 0x06);
  // Clamp Width (PC graphics)
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x06, 0x10);
  // Sync Control 1 (all automatic)
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x0E, 0x00);
  // H-PLL Pre-coast
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x12, 0x01);
  // H-PLL Post-coast
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x13, 0x00);
  // Misc control 2 (outputs enabled)
  i2c_write_byte (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x17, 0x02);

  usleep(1000000);

  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x14, buf, 1);
  printf ("Sync Detect = $%X\n", buf[0]);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x37, &buf[0], 1);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x38, &buf[1], 1);
  printf ("Lines Per Frame Status = $%02X%02X\n", buf[1] & 0x0F, buf[0]);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x39, &buf[0], 1);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x3A, &buf[1], 1);
  printf ("Clocks Per Line Status = $%02X%02X\n", buf[1] & 0x0F, buf[0]);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x3B, buf, 1);
  printf ("Hsync Width = $%X\n", buf[0]);
  i2c_read_bytes (VAI_I2C_MASTER_0_BASE, TVP7002_A, 0x3C, buf, 1);
  printf ("Vsync Width = $%X\n", buf[0]);

  printf ("Done!\n");
  while (1)
    usleep (100000);
}
