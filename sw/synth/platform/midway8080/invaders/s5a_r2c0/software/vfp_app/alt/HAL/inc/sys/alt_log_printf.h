/*
 * Basic header to disable this part of the Altera HAL.
 */
#ifndef _ALT_LOG_PRINTF_H_
#define _ALT_LOG_PRINTF_H_

/* logging is off, set all relevant macros to null */
#define ALT_LOG_PRINT_BOOT(...)
#define ALT_LOG_PRINTF(...)
#define ALT_LOG_JTAG_UART_ISR_FUNCTION(base, dev) 
#define ALT_LOG_JTAG_UART_ALARM_REGISTER(dev, base) 
#define ALT_LOG_SYS_CLK_HEARTBEAT()
#define ALT_LOG_PUTS(str) 
#define ALT_LOG_WRITE_FUNCTION(ptr,len) 

#endif
