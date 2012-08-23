/*
 *  This file implements simple console IO via JTAG UART.
 *
 *  Based on no_cpu/console.c
 *  COPYRIGHT (c) 1989-1999.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  Altera-specific code is
 *  COPYRIGHT (c) 2005-2006 Kolja Waschk, rtemsdev/ixo.de
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.com/license/LICENSE.
 *
 *  $Id: console.c,v 1.7 2009/11/30 04:53:31 ralf Exp $
 */

#define NO_BSP_INIT

#include <bsp.h>
#include <rtems/libio.h>


#include "system.h"
#include "nios2.h"

#ifdef __ALTERA_AVALON_JTAG_UART
#include "altera_avalon_jtag_uart_regs.h"
#endif

static unsigned int jtag_base = 0;

void console_initialize_hardware(void)
{
  jtag_base = JTAG_UART_0_BASE;
}

/*  is_character_ready
 *
 *  If a character is available, this routine reads it and stores
 *  it in
 *  reads the character and stores
 *
 *  Input parameters: NONE
 *
 *  Output parameters:  NONE
 *
 *  Return values:
 */

bool is_character_ready(char *ch)
{
  unsigned int data = IORD_ALTERA_AVALON_JTAG_UART_DATA(jtag_base);

  if (data & ALTERA_AVALON_JTAG_UART_DATA_RVALID_MSK)
    {
        *ch = (data & ALTERA_AVALON_JTAG_UART_DATA_DATA_MSK)
              >> ALTERA_AVALON_JTAG_UART_DATA_DATA_OFST;
        return true;
    };

    return false;
}

/*
 *  This routine reads a character from the SOURCE.
 *
 *  Input parameters: NONE
 *
 *  Output parameters:  NONE
 *
 *  Return values:
 *    character read from SOURCE
 */

int console_inbyte_nonblocking(int minor)
{
  char ch;
  /*
   *  Wait until a character is available.
   */

  if (is_character_ready(&ch))
    return ch;
  return -1;
}

/*
 *  This routine transmits a character out the SOURCE.  It may support
 *  XON/XOFF flow control.
 *
 *  Input parameters:
 *    ch  - character to be transmitted
 *
 *  Output parameters:  NONE
 */

void BSP_console_outbyte_polled(char ch)
{
  /*
   *  Wait for the transmitter to be ready.
   *  Check for flow control requests and process.
   *  Then output the character.
   */

  while ((IORD_ALTERA_AVALON_JTAG_UART_CONTROL(jtag_base) &
          ALTERA_AVALON_JTAG_UART_CONTROL_WSPACE_MSK) == 0);

  IOWR_ALTERA_AVALON_JTAG_UART_DATA(jtag_base, ch);
}

void console_outbyte_polled(int minor, char ch)
{
  BSP_console_outbyte_polled(ch);
}

/*
 *  To support printk
 */

#include <rtems/bspIo.h>

BSP_output_char_function_type           BSP_output_char = BSP_console_outbyte_polled;
BSP_polling_getchar_function_type       BSP_poll_char = NULL;

