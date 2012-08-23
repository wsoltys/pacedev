#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <altera_avalon_spi_regs.h>
#include <altera_avalon_pio_regs.h>
#include <sys/alt_irq.h>

#include "system.h"
#include "queue.h"
#include "dbg_helper.h"
#include "spi_helper.h"

static alt_u8 mcu_pio_o_r = 0;

void mcu_pio_set (alt_u8 mask)
{
  mcu_pio_o_r |= mask;
	IOWR_ALTERA_AVALON_PIO_DATA(MCU_PIO_BASE, mcu_pio_o_r);
}

void mcu_pio_clr (alt_u8 mask)
{
  mcu_pio_o_r &= ~mask;
	IOWR_ALTERA_AVALON_PIO_DATA(MCU_PIO_BASE, mcu_pio_o_r);
}

int mcu_ep_rdy (alt_u8 ep_mask)
{
#if 0
	if ((IORD_ALTERA_AVALON_PIO_DATA(MCU_PIO_BASE) & ep_mask) == 0)
	  return (0);
#endif

  return (1);	  
}

//
// Module local variables
//

static rtems_isr_entry mcuspi_isr_old;
static void mcuspi_isr (rtems_vector_number vector);

void mcuspi_isr_enable(void)
{
  //alt_ic_irq_enable(MCU_SPI_IRQ_INTERRUPT_CONTROLLER_ID, MCU_SPI_IRQ);
  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Set_ienable(MCU_SPI_IRQ);
  os_interrupt_enable (level);
}

void mcuspi_isr_disable(void) 
{
  //alt_ic_irq_disable(MCU_SPI_IRQ_INTERRUPT_CONTROLLER_ID, MCU_SPI_IRQ);

  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Clear_ienable(MCU_SPI_IRQ);
  os_interrupt_enable (level);
}

// define our queues
QUEUE_DECLARE(spi_rx_q);
QUEUE_DECLARE(spi_tx_q);
QUEUE_DECLARE(ts_q);
QUEUE_DECLARE(eeprom_q);
QUEUE_DECLARE(ddc_q);
QUEUE_DECLARE(misc_q);
QUEUE_DECLARE(graphics_q);

static void mcuspi_init(void) 
{
	QUEUE_INIT(spi_rx_q);
	QUEUE_INIT(spi_tx_q);

	mcu_pio_clr(MCU_PIO_SPI_ERR);
	IORD_ALTERA_AVALON_SPI_STATUS(MCU_SPI_BASE);
	IOWR_ALTERA_AVALON_SPI_STATUS(MCU_SPI_BASE, 0);
	IOWR_ALTERA_AVALON_SPI_CONTROL(MCU_SPI_BASE, ALTERA_AVALON_SPI_CONTROL_IRRDY_MSK);

	//alt_ic_isr_register(MCU_SPI_IRQ_INTERRUPT_CONTROLLER_ID, MCU_SPI_IRQ, mcuspi_isr, 0, 0);
  rtems_interrupt_catch(mcuspi_isr, MCU_SPI_IRQ, &mcuspi_isr_old);

  // signal the MCU that the NIOS is ready for SPI
	mcu_pio_set(MCU_PIO_NIOS_RDY);
}

static void mcuspi_deinit(void) 
{
  rtems_isr_entry old;
  rtems_interrupt_catch(mcuspi_isr_old, MCU_SPI_IRQ, &old);
}

static os_events_t   spi_event;
static os_thread_t   spi_thread;

static void mcuspi_isr (rtems_vector_number vector)
{
	uint8_t ch;

	alt_u32 stat = IORD_ALTERA_AVALON_SPI_STATUS(MCU_SPI_BASE) & IORD_ALTERA_AVALON_SPI_CONTROL(MCU_SPI_BASE);

	if(stat & ALTERA_AVALON_SPI_STATUS_TOE_MSK) {
		//printf("toe\n");
		mcu_pio_set(MCU_PIO_SPI_ERR);
	}

	if(stat & ALTERA_AVALON_SPI_STATUS_ROE_MSK) {
		//printf("roe\n");
		mcu_pio_set(MCU_PIO_SPI_ERR);
	}

	// Clear other ISRs
	IOWR_ALTERA_AVALON_SPI_STATUS(MCU_SPI_BASE, 0);

	do {
		//printf("isr stat=%08lx\n", stat);
		// Handle RX
		if(stat & ALTERA_AVALON_SPI_STATUS_RRDY_MSK) {
			ch = IORD_ALTERA_AVALON_SPI_RXDATA(MCU_SPI_BASE);
//			printf("%02x", ch&0xff);
			QUEUE_PUSH(spi_rx_q, ch);
			
			// signal that we have an ETX
			if (ch == 0x03)
        os_events_send (&spi_event, &spi_thread);
		}
	
		// Handle TX
		if(stat & ALTERA_AVALON_SPI_STATUS_TRDY_MSK) {
	    mcu_pio_clr(MCU_PIO_SPI_ERR);
			if(!QUEUE_EMPTY(spi_tx_q)) {
				ch = QUEUE_POP_UNSAFE(spi_tx_q);
				IOWR_ALTERA_AVALON_SPI_TXDATA(MCU_SPI_BASE, ch);
				//printf("TX($%02X)\n", ch);
			} else {
	//			IOWR_ALTERA_AVALON_SPI_TXDATA(MCU_SPI_BASE, 0x55);
				IOWR_ALTERA_AVALON_SPI_CONTROL(MCU_SPI_BASE, ALTERA_AVALON_SPI_CONTROL_IRRDY_MSK);
				//printf("trdy done\n");
			}
		}

		stat = IORD_ALTERA_AVALON_SPI_STATUS(MCU_SPI_BASE) & IORD_ALTERA_AVALON_SPI_CONTROL(MCU_SPI_BASE);
	} while(stat & ALTERA_AVALON_SPI_STATUS_RRDY_MSK);

//	printf("rsi stat=%08x\n", stat);
}

int mcuspi_rx_pkt (alt_u8 *buf, alt_u16 buflen)
{
  alt_u16   pktlen = 0;
  alt_u8    ch, esc = 0;
  
	alt_irq_context ctx = alt_irq_disable_all();

  while (1)
  {
    // eat everything before STX
    while (QUEUE_PEEK(spi_rx_q, &ch) && ch != 0x02)
      QUEUE_POP_UNSAFE(spi_rx_q);
  
    // anything left?    
    if (QUEUE_EMPTY(spi_rx_q))
      break;
  
    // do we have an ETX?    
    if (QUEUE_FIND(spi_rx_q, 0x03) < 0)
      break;
  
    // remove STX from queue    
    QUEUE_POP_UNSAFE(spi_rx_q);
    
    // we have a whole packet
    while (pktlen < buflen)
    {
      alt_u16 cnt;
      
      if ((cnt = QUEUE_POP(spi_rx_q, &ch)) == 0)
        break;
      if (ch == 0x03)
        break;
  
      if (esc)
      {
        esc = 0;
        ch ^= 0x40;
      }
      else if ((esc = (ch == 0x0F)))
        --cnt;
  
      buf[pktlen] = ch;
      pktlen += cnt;
    }
    
    break;
  }
  
	alt_irq_enable_all(ctx);
  
  return (pktlen);
}

// Transmit bytes to SPI
void mcuspi_tx_pkt (uint8_t ep, uint8_t *buf, int len)
{
	int i;

  // insert the EP and the length
  buf[0] = 0x80|ep;
  buf[1] = (len-3) & 0xFF;
  buf[2] = ((len-3) >> 8) & 0xFF;

  #if SPI_DBG_LVL == 0
    PRINT (SPI_DBG_LVL, "SPI:->");
    DUMP (buf, len);
  #endif

	alt_irq_context ctx = alt_irq_disable_all();
	
  QUEUE_PUSH(spi_tx_q, 0x02);		
	for(i=0; i<len; ++i)
	  if (buf[i] == 0x02 || buf[i] == 0x03 || buf[i] == 0x0F || buf[i] == 0xAA)
    {
		  QUEUE_PUSH(spi_tx_q, 0x0F);		
		  QUEUE_PUSH(spi_tx_q, buf[i] ^ 0x40);		
    }
    else
		  QUEUE_PUSH(spi_tx_q, buf[i]);		
  QUEUE_PUSH(spi_tx_q, 0x03);		
	alt_irq_enable_all(ctx);

	// Enable TRDY ISR
	IOWR_ALTERA_AVALON_SPI_CONTROL(MCU_SPI_BASE, ALTERA_AVALON_SPI_CONTROL_IRRDY_MSK | ALTERA_AVALON_SPI_CONTROL_ITRDY_MSK);
}

static char *hexdump(uint8_t *pkt, uint16_t len) {
	static char buf[512];
	char *p=buf;
	int i;
	for(i=0 ; i<len; ++i)
		p += sprintf(p, " %02x", pkt[i]);

	return buf;
}

// Handle received packet
void mcu_rx_packet(uint8_t *pkt, uint16_t len) {
	PRINT (SPI_DBG_LVL, "rx_pkt: %s\n", hexdump(pkt, len));

#if 0
	if(pkt[0] == 0xf0) {
		mcuspi_tx(pkt, len);
	}

	// Loop IN endpoint data back to OUT endpoint
	if((pkt[0] & 0x80) == 0x80) {
		pkt[0] &= ~0x80;
		mcuspi_tx(pkt, len);
	}
#endif
}

extern alt_u8 gfx_buf[];
extern alt_u8 gfx_buf_len;
extern volatile alt_u8 gfx_buf_rdy;

extern volatile uint16_t loopback_seq;

static void
spi_intr_low (void* self)
{
  while (1)
  {
    unsigned int out;
    os_events_receive (&spi_event, 1, &out, 0);

  	// Packet RX buffer
  	static uint8_t rx_pkt[USB_PKT_SIZE];
  	static uint8_t rx_len = 0;
  
    while ((rx_len = mcuspi_rx_pkt (rx_pkt, USB_PKT_SIZE)) > 0)
  	{
      #if SPI_DBG_LVL == 0
        PRINT (SPI_DBG_LVL, "SPI:<-");
        DUMP (rx_pkt, rx_len);
      #endif
                
      for (int i=3; i<rx_len; i++)
      {
		    switch (rx_pkt[0])
		    {
		      case 0x00 :
            QUEUE_PUSH(ts_q, rx_pkt[i]);
		        break;
		      case 0x02 :
		        // copy packet to one of the non-graphics queues
	          switch (rx_pkt[3])
	          {
	            case 1 :
	              QUEUE_PUSH(eeprom_q, rx_pkt[i]);
	              break;
              case 2 :
                QUEUE_PUSH(ddc_q, rx_pkt[i]);
                break;
              case 3 :
                QUEUE_PUSH(misc_q, rx_pkt[i]);
                break;
              default :
                break;
	          }
		        break;
		      case 0x03 :
		        // copy packet to the graphics queue
            QUEUE_PUSH(graphics_q, rx_pkt[i]);
		        break;
	        default :
	          break;
		    }
		  }
  	}
  }
}

void spi_init (void)
{
  os_error_t e;

	QUEUE_INIT(ts_q);
	QUEUE_INIT(eeprom_q);
	QUEUE_INIT(ddc_q);
	QUEUE_INIT(misc_q);
	QUEUE_INIT(graphics_q);
  mcuspi_init ();

  if (os_events_create (&spi_event, 0) != os_successful)
    return;
    
  e = os_thread_create (&spi_thread,
                        spi_intr_low, (void *)0,
                        SPI_TASK_PRIORITY,
                        SPI_TASK_STACKSIZE, NULL);
  if (e != os_successful)
    return;
}

void spi_deinit (void)
{
  mcuspi_deinit ();
}
