#ifndef __SPI_HELPER_H__

#include "os-support.h"

#define USB_PKT_SIZE                (8*64)

// MCU_PIO
#define MCU_PIO_EP3_RDY             (1<<4)
#define MCU_PIO_EP2_RDY             (1<<3)
#define MCU_PIO_EP1_RDY             (1<<2)
#define MCU_PIO_SPI_IRQ             (1<<1)
  #define MCU_PIO_SPI_ERR             MCU_PIO_SPI_IRQ
#define MCU_PIO_NIOS_RDY            (1<<0)

extern volatile int mcuspi_rx;

void mcu_pio_set (alt_u8 mask);
void mcu_pio_clr (alt_u8 mask);
int mcu_ep_rdy (alt_u8 ep_mask);

void mcuspi_isr_enable(void);
void mcuspi_isr_disable(void);
void spi_init (void);
void spi_deinit (void);

void mcuspi_tx_pkt(uint8_t ep, uint8_t *buf, int len);

static inline int mcuspi_is_valid_cmd (uint8_t ch)
{
	return (ch & ~0x3) == 0 
		|| (ch & ~0x3) == 0x80
		|| (ch == 0xf0);
}

void mcu_rx_packet(uint8_t *pkt, uint16_t len);

#endif
