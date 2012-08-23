#ifndef __BRAEMAC_UART__
#define __BRAEMAC_UART__

// UART register map
#define UART_REG_CONTROL            0x00
#define UART_REG_LED                0x01
#define UART_REG_STATUS             0x02
#define UART_REG_BAUD_DIVIDER       0x03
#define UART_REG_INTERRUPT          0x04
#define UART_REG_DATA               0x05
#define UART_REG_LINE_CONTROL       0x05
#define UART_REG_TXRDY_LVL          0x06
#define UART_REG_RX_ADDR1_MASK1     0x06
#define UART_REG_TX_BUFDEPTH        0x06
#define UART_REG_RXRDY_LVL          0x07
#define UART_REG_RX_ADDR2_MASK2     0x07
#define UART_REG_RX_BUFDEPTH        0x07

// UART_REG_CONTROL
#define UART_TXGO                   (1<<0)
#define UART_TXGOAC                 (1<<1)
#define UART_BAUDGO                 (1<<2)
#define UART_RXGO                   (1<<3)
#define UART_RTS                    (1<<4)
#define UART_RTSA                   (1<<5)
#define UART_CTSA                   (1<<6)
#define UART_FILT1                  (1<<8)
#define UART_FILT2                  (1<<9)
#define UART_RXBUFCLR               (1<<13)
#define UART_TXBUFCLR               (1<<14)
#define UART_RESET                  (1<<15)

// UART_REG_LED
#define UART_RXLED                  (1<<3)
#define UART_TXLED                  (1<<2)
#define UART_RXMAN                  (1<<1)
#define UART_TXMAN                  (1<<0)

// UART_REG_STATUS/UART_REG_INTERRUPT
#define UART_TXIDLE                 (1<<0)
#define UART_TRDY                   (1<<1)
#define UART_TOVF                   (1<<2)
#define UART_RRDY                   (1<<3)
#define UART_RTSp                   (1<<4)
#define UART_RTSs                   (1<<5)
#define UART_CTSs                   (1<<6)
#define UART_CTSp                   (1<<7)
#define UART_PE                     (1<<8)
#define UART_FE                     (1<<9)
#define UART_BE                     (1<<10)
#define UART_NF                     (1<<11)
#define UART_ROVF                   (1<<12)
#define UART_BRDC                   (1<<13)

// UART_REG_LINE_CONTROL
#define UART_PARITY_ODD             (1<<9)
#define UART_PARITY_ENABLE          (1<<8)
#define UART_DATA_BITS_8            (0x00<<4)
#define UART_DATA_BITS_9            (0x01<<4)
#define UART_DATA_BITS_7            (0x11<<4)
#define UART_STOP_BITS_1            0x02
#define UART_STOP_BITS_1_5          0x03
#define UART_STOP_BITS_2            0x04

#endif
