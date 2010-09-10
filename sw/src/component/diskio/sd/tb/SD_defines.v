//Read the documentation before changing values

`define BIG_ENDIAN
//`define LITLE_ENDIAN

`define SIM
//`define SYN

`define IRQ_ENABLE
`define ACTEL

//`define CUSTOM
`define ALTERA
//`define XLINX
//`define SIMULATOR

//MAX 255 BD
//BD size/4 

`ifdef ACTEL
   `define NR_O_BD_4 
   `define BD_WIDTH 4
   `define BD_SIZE 16       
   `define RAM_MEM_WIDTH_16
   `define RAM_MEM_WIDTH 16
  
`endif

`ifdef CUSTOM
   `define NR_O_BD_4 
   `define BD_WIDTH 5
   `define BD_SIZE 32       
   `define RAM_MEM_WIDTH_16
   `define RAM_MEM_WIDTH 16
`endif

`define RESEND_MAX_CNT 3

`ifdef SYN
  `define RESET_CLK_DIV 1
  `define MEM_OFFSET 4
`endif

`ifdef SIM
  `define RESET_CLK_DIV 0
  `define MEM_OFFSET 1
`endif

//SD-Clock Defines ---------
//Use bus clock or a seperate clock
`define SD_CLK_BUS_CLK
//`define SD_CLK_SEP

// Use of internal clock divider
//`define SD_CLK_STATIC
`define SD_CLK_DYNAMIC


//SD DATA-transfer defines---
`define BLOCK_SIZE 512
`define SD_BUS_WIDTH_4
`define SD_BUS_W 4

//at 512 bytes per block, equal 1024 4 bytes writings with a bus width of 4, add 2 for startbit and Z bit.
//Add 18 for crc, endbit and z.
`define BIT_BLOCK 1044
`define CRC_OFF 19
`define BIT_BLOCK_REC 1024
`define BIT_CRC_CYCLE 16


//FIFO defines---------------
`define FIFO_RX_MEM_DEPTH 4
`define FIFO_RX_MEM_ADR_SIZE 3

`define FIFO_TX_MEM_DEPTH 4
`define FIFO_TX_MEM_ADR_SIZE 3
//---------------------------









