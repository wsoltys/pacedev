#include <stdio.h>
#include <stdlib.h>

#include <altera_avalon_pio_regs.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_irq.h>
#include "system.h"

#include "os-support.h"

#include "veb.h"
#include "dbg_helper.h"
#include "usb_helper.h"

void init_uhe (void);
void led_enable (int mask, int enable);
void usb_led_enable (int mask, int enable);
int system_base_init (void);

void
Init (rtems_task_argument arg)
{
  PRINT (0, "\n\n" HARDWARE_VARIANT " Video Expansion Board Software v%d.%d.%d\n", 
         VER_MAJOR, VER_MINOR, VER_REVISION);
  
  PRINT (0, "Starting runtime ... \n");

  os_start ();
  
	#ifdef BUILD_ENABLE_USB
  init_uhe ();
	#endif

#if 1
  led_enable (LED_ALL ,0);
  usb_led_enable (USB_LED_ALL, 0);
  usb_led_enable (USB_LED_SPARE | USB_LED_CLIENT | USB_LED_HOST, 1);
#endif
  
	system_base_init ();

  #ifdef BUILD_ENABLE_USB
    PRINT (0, "#define BUILD_ENABLE_USB\n");
    if (init_usb () < 0)
      PRINT (0, "init_usb() failed!\n");
  #endif

  #ifdef BUILD_ENABLE_DEBUG_SHELL
    debug_shell ();
  #endif
  
  os_thread_del_self ();
}
