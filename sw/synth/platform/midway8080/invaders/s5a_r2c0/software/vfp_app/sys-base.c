#include <stdlib.h>
#include <io.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include "system.h"

#include "veb.h"
#include "ow.h"
#include "i2c_master.h"
#include "usb_helper.h"
#include "dbg_helper.h"

#include "os-support.h"

#ifndef BUILD_MINIMAL
#include <stdio.h>
#endif

uint32_t debug_pio_in = 0;

static os_thread_t system_base_thread;

void
s5a_watchdog_reset (void)
{
  PRINT (0, "generating watchdog\n");
  while (1);
}

void led_enable (int mask, int enable)
{
  static uint32_t led_pio_out = (3<<30);

  led_pio_out &= ~mask;
  if (enable)
    led_pio_out |= mask;

  IOWR_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE, led_pio_out);
}

void usb_led_enable (int mask, int enable)
{
  static uint32_t usb_pio_out = 0 & USB_PIO_DIR;
  
  mask &= USB_PIO_DIR;
  usb_pio_out &= ~mask;
  if (enable)
    usb_pio_out |= mask;

  IOWR_ALTERA_AVALON_PIO_DATA (USB_PIO_BASE, usb_pio_out);
}

static os_mutex_t		   restart_mutex;
static os_events_t     timer_60Hz_wait;
static uint32_t        timer_60Hz_irq;
static rtems_isr_entry timer_60Hz_isr_old;

static void timer_60Hz_isr (rtems_vector_number vector)
{
  static int count = 0;
  if (++count == 60)
  {
    timer_60Hz_irq |= 1;
    count = 0;
  }

  // acknowledge timer interrupt
  IOWR (TIMER_60HZ_BASE, 0, 0);

  #ifndef BUILD_ENABLE_SYNCHRONISERS
    #if 0
      ANIMATE_FRAME(0);
      ANIMATE_FRAME(1);
    #else
      // new update method
      sync0_irq |= 1;
      sync1_irq |= 1;
    #endif
  #endif

  //os_events_send (&timer_60Hz_wait, 1);
}

static void timer_60Hz_isr_enable (void)
{
  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Set_ienable(TIMER_60HZ_IRQ);
  os_interrupt_enable (level);
}

static void timer_60Hz_isr_disable (void)
{
  os_interrupt_level level;
  os_interrupt_disable (level);
  Nios2_Clear_ienable(TIMER_60HZ_IRQ);
  os_interrupt_enable (level);
}

static void timer_60Hz_isr_init (void)
{
  // register and enable the video status update
  rtems_interrupt_catch(timer_60Hz_isr, TIMER_60HZ_IRQ, &timer_60Hz_isr_old);
  //start timer, continuous mode, enable interrupt
  IOWR(TIMER_60HZ_BASE,1,(1<<2)|(1<<1)|(1<<0));
}

void timer_60Hz_isr_deinit (void)
{
  rtems_isr_entry old;
  timer_60Hz_isr_disable ();
  rtems_interrupt_catch(timer_60Hz_isr_old, TIMER_60HZ_IRQ, &old);
}

void hid_keybd_event (uint16_t vendor, uint16_t product)
{
	PRINT (0, "%s($%04X,$%04X)\n", __FUNCTION__, vendor, product);
}

void system_base_task (void* data)
{
  struct    timespec ticks_r;
  uint32_t  usec_r;
  
  rtems_clock_get_uptime (&ticks_r);
  usec_r = (uint32_t)ticks_r.tv_sec * 1000000 + (uint32_t)ticks_r.tv_nsec / 1000;

  #ifdef BUILD_INCLUDE_DEBUG
    //dump_heap_info ();
  #endif
  
  // set direction registers for USB PIO
  IOWR_ALTERA_AVALON_PIO_DIRECTION (USB_PIO_BASE, USB_PIO_DIR);

  debug_pio_in = IORD_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE);
  debug_pio_in |= 0xFF;
  PRINT (0, "debug_pio_in = $%08lX\n", debug_pio_in);

  uint8_t romid[8];
  int result;
  result = ow_read_romid(ONE_WIRE_INTERFACE_0_BASE, romid);
  #ifdef BUILD_INCLUDE_DEBUG
  	if (result != OW_RESULT_OK)
      PRINT (0, "ow_read_romid() failed! (%d)\n", result);
    else
    {
      PRINT (0, "ROMID="); 
      DUMP (romid, 8);
    }
  #endif

  PRINT (0, "Executing one-off NIOS/hardware initialisation\n");

#if 0
  // for now, (re)init EE data if we can't read the header
  // dbgio(4) is pin10 on the dbgio hdr
  if (((debug_pio_in & (1<<4)) == 0) || 
      EE_ReadData (&ee_map) != EE_OP_SUCCESS)
  {
    PRINT (0, "Initialising EEPROM data...\n");
    //EE_InitAndWriteEdid ();
    EE_InitAndWriteData ();
  }
  else
    PRINT (0, "Detected initialised EEPROM!\n");

  #ifdef BUILD_INCLUDE_DEBUG
    EE_DumpFormattedData (ee_data);
    // dump data directly from EEPROM (unformatted)
    //EE_DumpData ();
  #endif
#endif

  // turn all the leds off
  led_enable (LED_ALL ,0);
  usb_led_enable (USB_LED_ALL, 0);
  // we should only turn these on when host appears in pdev
  // - USB_LED_HOST is only an indicator
  // - USB_LED_CLIENT also powers the host (downstream) port 
  //    from the client (upstream) port
  usb_led_enable (USB_LED_HOST|USB_LED_CLIENT, 1);

  // initialise DVI out transmitter
  //tfp410_init ();

  timer_60Hz_isr_init ();      

  // enable SPI channel to MCU
  //HOST_IF_INIT ();
  
  while (1)
  {
    timer_60Hz_isr_enable ();  

    PRINT (0, "Main loop running...\n");
    led_enable (LED_NIOS_RDY, 1);

    uint8_t loop_break = 0;
    
    while (!loop_break)
    {
      if (timer_60Hz_irq)
      {
        timer_60Hz_irq = 0;
      }

      #if 0
        // set the video indicator LEDs
        led_enable (LED_VAI, vi_0_format==EE_VI_ANALOGUE && CTI_OK(vi_0_pio_stat, egmvid_stat, cti0_stat));
        led_enable (LED_VDI, vi_0_format!=EE_VI_ANALOGUE && CTI_OK(vi_0_pio_stat, egmvid_stat, cti0_stat));
        led_enable (LED_VSI, CTI_STAT_OK(cti1_stat));
        led_enable (LED_VAO|LED_VDO, ITC_STAT_OK(itc0_stat));
        led_enable (LED_VLI,CTI_STABLE(egmvid_stat));
      #endif

      // 'alive' LED
      static uint8_t alive_led = 0;
      struct timespec ticks;
      uint32_t usec;

      rtems_clock_get_uptime (&ticks);
      usec = (uint32_t)ticks.tv_sec * 1000000 + (uint32_t)ticks.tv_nsec / 1000;
      if ((usec - usec_r) > 250000)
      {
        static int count = 0;
        if (++count == 2.5*4)
        {
          //dump_video_stats (0);
          //dump_heap_info ();
          count = 0;
        }

        led_enable (LED_NIOS_RDY, alive_led);
        alive_led ^= 1;
        usec_r = usec;
      }

      // for debugging only
      //#ifdef BUILD_INCLUDE_DEBUG
      debug_pio_in = IORD_ALTERA_AVALON_PIO_DATA (DEBUG_PIO_BASE);
      debug_pio_in |= 0xFF;
      if ((debug_pio_in & (1<<7)) == 0)
        loop_break = 1;
      //#endif
    }

    // de-activate NIOS_RDY LED
    led_enable (LED_NIOS_RDY, 0);

    // disable and de-register all interrupts
    timer_60Hz_isr_disable ();

    PRINT (0, "loop_break=1\n");
  }

  timer_60Hz_isr_deinit ();      
}

void joy_event (uint8_t *buf, uint16_t len)
{
  // Chris' joystick
  // 0 left-right (signed) -ve=left
  // 1 up-down -ve=up
  // 2 b1,b2,b3,b4,b5,start,coin,service (b0-b7)

/*  { S_1P_UP_GPIO, S_1P_UP_PIN },
  { S_1P_LEFT_GPIO, S_1P_LEFT_PIN },
  { S_1P_RIGHT_GPIO, S_1P_RIGHT_PIN },
  { S_1P_DOWN_GPIO, S_1P_DOWN_PIN },
  { S_1P_BUTTON1_GPIO, S_1P_BUTTON1_PIN },
  { S_1P_BUTTON2_GPIO, S_1P_BUTTON2_PIN },
  { S_1P_BUTTON3_GPIO, S_1P_BUTTON3_PIN },
  { S_1P_BUTTON4_GPIO, S_1P_BUTTON4_PIN },
  { S_1P_BUTTON5_GPIO, S_1P_BUTTON5_PIN },
  { S_1P_COIN_GPIO, S_1P_COIN_PIN },
  { S_1P_START_GPIO, S_1P_START_PIN },
  { S_SERVICE_SW_GPIO, S_SERVICE_SW_PIN },
  { S_TILT_SW_GPIO, S_TILT_SW_PIN },
  { S_TEST_SW_GPIO, S_TEST_SW_PIN },
  { S_TEST_SW_GPIO, S_TEST_SW_PIN },
  { S_TEST_SW_GPIO, S_TEST_SW_PIN },
  { S_2P_UP_GPIO, S_2P_UP_PIN },
  { S_2P_LEFT_GPIO, S_2P_LEFT_PIN },
  { S_2P_RIGHT_GPIO, S_2P_RIGHT_PIN },
  { S_2P_DOWN_GPIO, S_2P_DOWN_PIN },
  { S_2P_BUTTON1_GPIO, S_2P_BUTTON1_PIN },
  { S_2P_BUTTON2_GPIO, S_2P_BUTTON2_PIN },
  { S_2P_BUTTON3_GPIO, S_2P_BUTTON3_PIN },
  { S_2P_BUTTON4_GPIO, S_2P_BUTTON4_PIN },
  { S_2P_BUTTON5_GPIO, S_2P_BUTTON5_PIN },
  { S_2P_COIN_GPIO, S_2P_COIN_PIN },
  { S_2P_START_GPIO, S_2P_START_PIN },
*/  
  uint32_t jamma = 0;

  if ((int8_t)buf[1] < -40)
    jamma |= (1<<0);
  if ((int8_t)buf[0] < -40)
    jamma |= (1<<1);
  if ((int8_t)buf[0] > 40)
    jamma |= (1<<2);
  if ((int8_t)buf[1] > 40)
    jamma |= (1<<3);
  if (buf[2] & (1<<0))
    jamma |= (1<<4);
  if (buf[2] & (1<<1))
    jamma |= (1<<5);
  if (buf[2] & (1<<2))
    jamma |= (1<<6);
  if (buf[2] & (1<<3))
    jamma |= (1<<7);
  if (buf[2] & (1<<4))
    jamma |= (1<<8);
  //if (buf[2] & (1<<6))
  if (buf[2] & (1<<2))
    jamma |= (1<<9);
  if (buf[2] & (1<<5))
    jamma |= (1<<10);
  if (buf[2] & (1<<7))
    jamma |= (1<<11);
    
  IOWR_ALTERA_AVALON_PIO_DATA (JAMMA_PIO_BASE, ~jamma);
  IOWR_ALTERA_AVALON_PIO_DATA (SPI_PIO_BASE, (1<<0));   // go
  IOWR_ALTERA_AVALON_PIO_DATA (SPI_PIO_BASE, 0);        // stop
}

static uint32_t kbd_override = 0;

void kbd_attach_event (uint8_t attach)
{
	PRINT (0, "%s(%d)\n", __FUNCTION__, attach);
	
	if (attach)
		kbd_override = (1<<31);
	else
		kbd_override = 0;

  IOWR_ALTERA_AVALON_PIO_DATA (KEYBD_PIO_BASE, kbd_override);
}

#define KBD_OVERRIDE	(1<<31)
#define KBD_GO				(1<<30)
#define KBD_MAKE			(1<<15)

#define SEND(n)																					\
	keybd = kbd_override | KBD_GO | (n);									\
	IOWR_ALTERA_AVALON_PIO_DATA (KEYBD_PIO_BASE, keybd);	\
	keybd &= ~KBD_GO;																			\
	IOWR_ALTERA_AVALON_PIO_DATA (KEYBD_PIO_BASE, keybd)

#define SEND_MAKE(n)		SEND(KBD_MAKE|(n))
#define SEND_BREAK(n)		SEND(n)

void kbd_event (uint8_t *buf, uint16_t len)
{
	static uint8_t buf_r[16] = 
	{ 
		0, 0, 0, 0, 0, 0, 0, 0,  
		0, 0, 0, 0, 0, 0, 0, 0
	};

	// 0=PS/2, 1=JAMMA
	static uint8_t mode = 0;
	unsigned i;

  uint32_t keybd;

	// check for mode switch
	// <CTRL><ALT>
	if (buf[0] == 0x05)
	{
		// <K>
		if (buf[2] == 0x0E)
		{
			PRINT (0, "switched to KEYBOARD mode\n");
			SEND_BREAK(0x78|(1<<0));
			SEND_BREAK(0x78|(1<<2));
			SEND_BREAK(0x0E);
			mode = 0;
			return;
		}
		else
		// <J>
		if (buf[2] == 0x0D)
		{
			PRINT (0, "switched to JAMMA mode\n");
			SEND_BREAK(0x78|(1<<0));
			SEND_BREAK(0x78|(1<<2));
			SEND_BREAK(0x0D);
			mode = 1;
			return;
		}
	}
					
	if (mode == 0)
	{
		if (!kbd_override)
			return;

		for (i=0; i<8; i++)
		{
			if (buf_r[0] & (buf_r[0] ^ buf[0]) & (1<<i))
			{
				PRINT (0, "BREAK:b%d\n", i);
				SEND_BREAK(0x78|i);
			}
			if (buf[0] & (1<<i))
			{
				PRINT (0, "MAKE:b%d\n", i);
				SEND_MAKE(0x78|i);
			}						
		}
		
		for (unsigned i=1; i<len; i++)
		{
			if (buf_r[i] != 0 && buf[i] != buf_r[i])
			{
				// send a 'break' code
				PRINT (0, "BREAK:%#02x\n", buf_r[i]);
				SEND_BREAK(buf_r[i]);
			}
				
			if (buf[i] == 0)
				continue;
				
			PRINT (0, "MAKE:%#02x\n", buf[i]);
			SEND_MAKE(buf[i]);
		}
		
		memcpy (buf_r, buf, len);
	}
	else
	{
	  uint32_t jamma = 0;
	
		for (unsigned i=0; i<len; i++)
		{
			if (i == 0)
			{
				if (buf[i] & (1<<0))	jamma |= (1<<4);	// <CTRL>
				if (buf[i] & (1<<2))	jamma |= (1<<5);	// <ALT>
			}
			else
				switch (buf[i])
				{
					case 0x52 :		jamma |= (1<<0);		break;	// <UP>
					case 0x50 :		jamma |= (1<<1);		break;	// <LEFT>
					case 0x4F :		jamma |= (1<<2);		break;	// <RIGHT>
					case 0x51 :		jamma |= (1<<3);		break;	// <DOWN>
					case 0x1D :		jamma |= (1<<6);		break;	// <Z>
					case 0x1B :		jamma |= (1<<7);		break;	// <X>
					case 0x06 :		jamma |= (1<<8);		break;	// <C>
					case 0x22 :		jamma |= (1<<9);		break;	// <5>
					case 0x1E :		jamma |= (1<<10);		break;	// <1>
					case 0x3B :		jamma |= (1<<11);		break;	// <F2>
					default :
						break;
				}
					
		}
	
	  IOWR_ALTERA_AVALON_PIO_DATA (JAMMA_PIO_BASE, ~jamma);
	  IOWR_ALTERA_AVALON_PIO_DATA (SPI_PIO_BASE, (1<<0));   // go
	  IOWR_ALTERA_AVALON_PIO_DATA (SPI_PIO_BASE, 0);        // stop
	}  
}

#define INTRPT_STACKSIZE		(16*1024)

int
system_base_init (void)
{
	os_mutex_create (&restart_mutex);
	
  if (os_events_create (&timer_60Hz_wait, 0) != os_successful)
  {
    PRINT (0, "error: cannot creating timer_60Hz events\n");
  }
	
//	os_thread_create (timer_60Hz_task, NULL, INTRPT_TASK_PRIORITY+1,
//										INTRPT_STACKSIZE, NULL);

	// mainline function
  os_error_t e = os_thread_create (&system_base_thread,
                                   system_base_task, NULL,
                                   SYSTEM_BASE_TASK_PRIORITY,
                                   SYS_BASE_TASK_STACKSIZE, NULL);
  return e == os_successful;
}
